package newsrack.archiver;

import newsrack.NewsRack;
import newsrack.filter.Issue;
import newsrack.user.User;
import newsrack.util.StringUtils;
import newsrack.util.ThreadManager;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.TimerTask;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

/**
 * class <code>DownloadNewsTask</code> implements the functionality
 * of periodically downloading news.
 */

public class DownloadNewsTask extends TimerTask {
    /**
     * Initial delay after system startup before news is downloaded.
     */
    public static long INIT_DELAY = 0;
    /**
     * Time period between consecutive downloads
     */
    public static long PERIOD = 0;
    /**
     * Maximum number of attempts to download a feed and its articles
     */
    public static int MAX_ATTEMPTS = 0;
    /**
     * Number of parallel threads for downloading news
     */
    public static int DOWNLOAD_MAX_THREADS;
    public static int CLASSIFY_MAX_THREADS;
    /* Logging output for this class. */
    private static Log _log = LogFactory.getLog(DownloadNewsTask.class);
    /**
     * Keep track of number of download and classifier tasks that have completed
     */
    private static Integer _completedDownloadsCount;
    private static Integer _completedIssuesCount;
    private static Date _lastDownloadTime = new Date();
    private static int _count = 0;

    private static int loadPropertyValue(String propName, int defaultVal) {
        String p = "";
        try {
            p = NewsRack.getProperty(propName);
            if (p == null) {
                if (_log.isInfoEnabled())
                    _log.info("Did not find property value for " + propName + "; Using default value - " + defaultVal);
                return defaultVal;
            } else {
                return Integer.parseInt(p);
            }
        } catch (NumberFormatException e) {
            _log.error("Exception parsing property " + propName + "; Got string - " + p);
            return defaultVal;
        }
    }

    public static void init() {
        INIT_DELAY = 1000 * loadPropertyValue("download.init_delay.secs", 60);
        PERIOD = 1000 * 60 * loadPropertyValue("download.period.mins", 144);
        MAX_ATTEMPTS = loadPropertyValue("download.feed.max_attempts", 10);
        DOWNLOAD_MAX_THREADS = loadPropertyValue("download.max_threads", 20);
        CLASSIFY_MAX_THREADS = loadPropertyValue("classify.max_threads", 5);
        _log.info("Initialized DNT");
    }

    public static boolean shutDownThreadPool(ExecutorService tpool) {
        try {
            tpool.shutdown();
            if (!tpool.awaitTermination(60, TimeUnit.SECONDS)) {
                _log.error("Pool did not terminate in 60 seconds.  Shutting it down now");
                tpool.shutdownNow();
            }
            return true;
        } catch (InterruptedException ie) {
            tpool.shutdownNow();
            Thread.currentThread().interrupt();
            return false;
        }
    }

    /**
     * Returns the time of the last download
     */
    public static Date getLastDownloadTime() {
        return _lastDownloadTime;
    }

    /**
     * Runs the download news task -- news is downloaded from all
     * active news feeds across all registered users. *
     */
    public void run() {
        if (NewsRack.testing() || NewsRack.isTrue("readonly"))
            return;

        // Check if the site crawlers file has been modified
        // since last read.  If so, cancel all tasks and reschedule!
        if (SiteCrawlerTask.checkCrawlersFile())
            return;

        if (_log.isInfoEnabled()) {
            _log.info("---------------------------------------------------------");
            _log.info("DNT: Called " + _count + " at time " + (new java.util.Date()));
        }
        _count++;

        // 1. INITIALIZATIONS
        // 1a. Record the thread with the thread manager!
        ThreadManager.recordThread(Thread.currentThread());

        // 1b. Initialize counters
        // IMPORTANT: These counters have to be initialized BEFORE the task threads are spawned
        _completedDownloadsCount = 0;
        _completedIssuesCount = 0;

        try {
            // Create a thread pool for processing feeds in parallel
            ExecutorService tpool = Executors.newFixedThreadPool(DOWNLOAD_MAX_THREADS);

            int issueCount = 0;
            Collection<User> users = User.getAllUsers();
            for (User u : users) {
                try {
                    u.doPreDownloadBookkeeping();
                } catch (Exception e) {
                    _log.error("ERROR:", e);
                }
            }

            // Randomize the download by shuffling the list
            int feedCount = 0;
            List<Feed> activeFeeds = Feed.getActiveFeeds();
            java.util.Collections.shuffle(activeFeeds);
            for (Feed f : activeFeeds) {
                feedCount++;
                tpool.execute(new FeedDownloader(f));
            }

            // Loop until all the download tasks are complete
            int noChangeIntervals = 0;
            int prev = 0;
            while (_completedDownloadsCount < feedCount) {
                StringUtils.sleep(30);
                _log.info(" ... FDT: WAITING ... " + _completedDownloadsCount + " of " + feedCount + " completed ...");

                if (_completedDownloadsCount == prev) {
                    noChangeIntervals++;

                    // Abort download if we have passed 30 minutes without making any progress
                    if (noChangeIntervals == 60) {
                        _log.error("No progress in news download for last 30 minutes ... Aborting download phase!");
                        break;
                    }
                } else {
                    prev = _completedDownloadsCount;
                    noChangeIntervals = 0;
                }
            }

            // Shut down the download thread pool .. if interrupted, the method will return false .. end execution in that case!
            if (!shutDownThreadPool(tpool)) {
                return;
                }

            // Clear the downloaded news table -- since we are done processing all of them
            NewsRack.getDBInterface().clearDownloadedNewsTable();

            for (User u : users) {
                u.doPostDownloadBookkeeping();
            }

            // Shut down the thread pool
            shutDownThreadPool(tpool);
        } finally {
            // 6. Update the time when news was last downloaded & processed
            _lastDownloadTime = new Date();

            // 7. Remove the thread from the thread manager!
            ThreadManager.removeThread(Thread.currentThread());
        }
    }

    /**
     * This class handles the download of a single news feed (RSS/Atom)
     * and all the news articles in that feed
     */
    private class FeedDownloader implements Runnable {
        private Feed feed;

        FeedDownloader(Feed feed) {
            this.feed = feed;
        }

        public void run() {
            boolean done = false;
            int count = 0;

            _log.info("For feed " + feed.getTag() + " download started!");

            while (!done && (count < MAX_ATTEMPTS)) {
                try {
                    count++;
                    feed.download();
                    // SSS FIXME: Yet to be implemented!
                    // feed.classifyNews();
                    done = true;
                } catch (Exception e) {
                    _log.error("Exception reading feed " + feed.getTag() + " with feed " + feed.getUrl(), e);
                }
            }

            if (done)
                _log.info("For feed " + feed.getTag() + " download complete!");
            else
                _log.error("For feed " + feed.getTag() + " aborting news download after " + MAX_ATTEMPTS + " attempts.");

            int mycount = 0;
            synchronized (_completedDownloadsCount) {
                _completedDownloadsCount++;
                mycount = _completedDownloadsCount;
                _log.info("Completed # " + _completedDownloadsCount);
            }

            // FIXME: Till we figure out why we are ending up with CLOSE_WAIT sockets because of mod_jk/tomcat problem,
            // periodically gc while downloading, so that this forces tomcat to release sockets
            if (mycount % 20 == 0) {
                System.gc();
            }
        }
    }

    /**
     * This class processes news for a single user and classifies
     * recently downloaded news for all the user's issues
     */
    private class NewsClassifier implements Runnable {
        private final Issue _i;

        NewsClassifier(Issue i) {
            _i = i;
        }

        public void run() {
            try {
                if (_i.getUser().concurrentProfileModification())
                    return;

                if (_i.isFrozen()) {
                    _log.info("For user " + _i.getUser().getUid() + ", issue " + _i.getName() + " is frozen!");
                    return;
                }

                // Initialize before classification
                _i.readInCurrentRSSFeed();

                _log.info("For user " + _i.getUser().getUid() + " and issue " + _i.getName() + ", starting classifying news!");

                Collection<Source> iSrcs = _i.getMonitoredSources();
                for (Source s : iSrcs) {
                    try {
                        Feed f = s.getFeed();
                        if (f.getUrl() == null) {
                            _log.error("ERROR? empty url for feed with key: " + f.getKey() + " for source " + s.getName());
                            continue;
                        }

                        Collection sNews = f.getDownloadedNews();
                        if (sNews != null)
                            _i.scanAndClassifyNewsItems(f, sNews);
                    } catch (Exception e) {
                        _log.error("Exception classifying news for source: " + s.getName() + " for issue: " + _i.getName() + " for user: " + _i.getUser().getUid(), e);
                    }
                }

                _log.info("For user " + _i.getUser().getUid() + " and issue " + _i.getName() + ", done classifying news!");

                // Now that all feeds are processed, store back classified news
                _i.updateRSSFeed();
                _i.storeNewsToArchive();
                _i.freeRSSFeed();    // Clean up after classification is done
                _i.unloadScanners();    // Free space allocated to scanners!
            } catch (Exception e) {
                _log.error("Exception classifying news for issue " + _i.getName());
                e.printStackTrace();
                return;
            } finally {
                synchronized (_completedIssuesCount) {
                    _completedIssuesCount++;
                }
            }
        }
    }
}
