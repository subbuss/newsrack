package newsrack.archiver;

import java.util.Date;
import java.util.Hashtable;
import java.util.List;
import java.util.Collection;
import java.util.TimerTask;

import newsrack.GlobalConstants;
import newsrack.filter.Issue;
import newsrack.user.User;
import newsrack.util.IOUtils;
import newsrack.util.StringUtils;
import newsrack.util.ThreadManager;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.concurrent.*;

/**
 * class <code>DownloadNewsTask</code> implements the functionality
 * of periodically downloading news.
 *
 * Original code : Subramanya Sastry.
 * June 4, 2007  : T Meyarivan changed code to use a thread pool for downloading / filter in parallel.
 * June 12, 2007 : Subramanya Sastry re-orged. Mary code and fixed some bugs.
 */

public class DownloadNewsTask extends TimerTask
{
   /** This class handles the download of a single news feed (RSS/Atom)
     * and all the news articles in that feed
     */ 
   private class FeedDownloader implements Runnable
   {
      private Feed feed;

      FeedDownloader(Feed feedx) { feed = feedx; }

      public void run()
      {
         List    sNews = null;
         boolean done  = false;
         int     count = 0;

         _log.info("For feed " + feed.getTag() + " download started!");

         while (!done && (count < MAX_ATTEMPTS)) {
            try {
               count++;
               feed.download();
               done = true;
            }
            catch (Exception e) {
               _log.error("Exception reading feed " + feed.getTag() + " with feed " + feed._feedUrl);
            }
         }

         if (done)
            _log.info("For feed " + feed.getTag() + " download complete!");
         else
            _log.error("For feed " + feed.getTag() + " aborting news download after " + MAX_ATTEMPTS + " attempts.");

         synchronized(_completedDownloadsCount) { _completedDownloadsCount++; _log.info("Completed # " + _completedDownloadsCount); }
      }
   }

   /** This class processes news for a single user and classifies
     * recently downloaded news for all the user's issues 
     */
   private class NewsClassifier implements Runnable
   {
      private final Issue _i;
       
      NewsClassifier(Issue i) { _i = i; } 

      public void run()
      {
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
				for (Source s: iSrcs) {
					try {
						Feed f = s.getFeed();
						if (f._feedUrl == null) {
							_log.error("ERROR? empty url for feed with key: " + f.getKey() + " for source " + s.getName());
							continue;
						}

         			Collection sNews = f.getDownloadedNews();
						if (sNews != null)
							_i.scanAndClassifyNewsItems(f, sNews);
					}
					catch (Exception e) {
						_log.error("Exception classifying news for source: " + s.getName() + " for issue: " + _i.getName() + " for user: " + _i.getUser().getUid(), e);
					}
				}
				 
				_log.info("For user " + _i.getUser().getUid() + " and issue " + _i.getName() + ", done classifying news!");

					 // Now that all feeds are processed, store back classified news
				_i.updateRSSFeed();
				_i.storeNewsToArchive();
				_i.freeRSSFeed(); // Clean up after classification is done
         } 
         catch (Exception e) {
            _log.error("Exception classifying news for issue " + _i.getName());
            e.printStackTrace();
            return;
         }
         finally {
            synchronized(_completedIssuesCount) { _completedIssuesCount++; }
         }
      }
   }

   /* Logging output for this class. */
   private static Log _log = LogFactory.getLog(DownloadNewsTask.class);
    
   /** Initial delay after system startup before news is downloaded. */
   public static long INIT_DELAY = 10 * 60 * 1000;
    
   /** Time period between consecutive downloads */
   public static long PERIOD     = 144 * 60 * 1000; // run every 144 minutes (10 times a day)

   /** Maximum number of attempts to download a feed and its articles */
   public static int MAX_ATTEMPTS = 10;

   /** Number of parallel threads for downloading news */
   public static int DOWNLOAD_MAX_THREADS;
   public static int CLASSIFY_MAX_THREADS;
    
   /** Keep track of number of download and classifier tasks that have completed */
   private static Integer _completedDownloadsCount;
   private static Integer _completedIssuesCount;

   private static Date _lastDownloadTime = new Date();
   private static int  _count            = 0; 

   private static int loadPropertyValue(String propName, int defaultVal)
   {
      String p = "";
      try {
         p = GlobalConstants.getProperty(propName);
         if (p == null) {
            if (_log.isInfoEnabled()) _log.info("Did not find property value for " + propName + "; Using default value - " + defaultVal);
            return defaultVal;
         }
         else {
            return Integer.parseInt(p);
         }
      }
      catch (NumberFormatException e) {
         _log.error("Exception parsing property " + propName + "; Got string - " + p);
         return defaultVal;
      }
   }

   public static void init()
   {
      INIT_DELAY   = 1000 * loadPropertyValue("download.init_delay.secs", 60);
      PERIOD       = 1000 * 60 * loadPropertyValue("download.period.mins", 144);
      MAX_ATTEMPTS = loadPropertyValue("download.feed.max_attempts", 10);
      DOWNLOAD_MAX_THREADS  = loadPropertyValue("download.max_threads", 20);
      CLASSIFY_MAX_THREADS  = loadPropertyValue("classify.max_threads", 5);
		_log.info("Initialized DNT");
   }

	public static boolean shutDownThreadPool(ExecutorService tpool)
	{
		try {
			tpool.shutdown();
			if (!tpool.awaitTermination(60, TimeUnit.SECONDS)) {
				_log.error("Pool did not terminate in 60 seconds.  Shutting it down now");
				tpool.shutdownNow();
			}
			return true;
		}
		catch (InterruptedException ie) {
			tpool.shutdownNow();
			Thread.currentThread().interrupt();
			return false;
		}
	}

    
    /** Returns the time of the last download */
   public static Date getLastDownloadTime() { return _lastDownloadTime; }

   /** Runs the download news task -- news is downloaded from all
    * active news feeds across all registered users. **/
   public void run()
   {
      if (GlobalConstants.testing() || GlobalConstants.isTrue("readonly"))
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

         int feedCount = 0;
			Collection<Feed> activeFeeds = Feed.getActiveFeeds();
			for (Feed f: activeFeeds) {
            feedCount++;
            tpool.execute(new FeedDownloader(f));
			}

            // Loop until all the download tasks are complete
			int noChangeIntervals = 0;
			int prev              = 0;
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
				}
				else {
					prev = _completedDownloadsCount;
					noChangeIntervals = 0;
				}
         }

            // Shut down the download thread pool .. if interrupted, the method will return false .. end execution in that case!
			if (!shutDownThreadPool(tpool))
				return;

				// Create a thread pool for processing downloaded articles
      	tpool = Executors.newFixedThreadPool(CLASSIFY_MAX_THREADS);

         int issueCount = 0;
         Collection<User> users = User.getAllUsers();
			for (User u: users) {
				try { u.doPreDownloadBookkeeping(); } catch (Exception e) { _log.error("ERROR:", e); }
			}

            // Parse and classify news for every validated issue 
      	List<Issue> issues = User.getAllValidatedIssues();
			for (Issue i: issues) {
				tpool.execute(new NewsClassifier(i));
				issueCount++;
         }

            // loop until all the news classifier tasks are complete
			noChangeIntervals = 0;
			prev              = 0;
         while (_completedIssuesCount < issueCount) {
            StringUtils.sleep(30);
            _log.info(" ... NCT: WAITING ... " + _completedIssuesCount + " of " + issueCount + " completed ...");

				if (_completedIssuesCount == prev) {
					noChangeIntervals++;

						// Abort filtering if we have passed 30 minutes without making any progress
					if (noChangeIntervals == 60) {
						_log.error("No progress in news filtering for last 30 minutes ... Aborting filtering phase!");
						break;
					}
				}
				else {
					prev = _completedIssuesCount;
					noChangeIntervals = 0;
				}
         }
            
			for (User u: users)
            u.doPostDownloadBookkeeping();

				// Shut down the thread pool
			shutDownThreadPool(tpool);
      }
      finally {
            // 6. Update the time when news was last downloaded & processed
         _lastDownloadTime = new Date();

            // 7. Remove the thread from the thread manager!
         ThreadManager.removeThread(Thread.currentThread());
      }
   }
}
