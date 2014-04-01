package newsrack.util;

import newsrack.archiver.DownloadNewsTask;
import newsrack.archiver.SiteCrawlerTask;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.io.File;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Timer;

/**
 * class <code>ThreadManager</code> keeps track of threads
 * that are created .. and handles the proper shutting down
 * of all threads before shutdown.
 */
public class ThreadManager {
    private static final Hashtable _createdThreads = new Hashtable();
    // Logging output for this plug in instance.
    private static Log _log = LogFactory.getLog(newsrack.util.ThreadManager.class);
    private Timer _newsDownloadTimer;

    public ThreadManager() {
    }

    /**
     * Records a thread that has been spawned -- this recording
     * helps stop it at system shut down time.
     *
     * @param t Thread that has been spawned
     */
    public static void recordThread(final Thread t) {
        if (_log.isInfoEnabled()) _log.info("Recording thread " + t);
        _createdThreads.put(t, t);
    }

    public static void removeThread(final Thread t) {
        if (_log.isInfoEnabled()) _log.info("Removing thread " + t);
        _createdThreads.remove(t);
    }

    public void initialize(final File siteCrawlersFile) {
        try {
            _log.info("TM: Initializing ...");

            // Allocate a timer and make the thread a daemon thread
            final Timer t = new Timer(true);
            _newsDownloadTimer = t;

            // Register known crawlers with the site crawler
            SiteCrawlerTask.registerSiteCrawlers(this, t, siteCrawlersFile);

            // Schedule news download every "dnt.PERIOD" millisecs
            // after NewsRack is started
            DownloadNewsTask.init();
            final DownloadNewsTask dnt = new DownloadNewsTask();
            t.scheduleAtFixedRate(dnt, DownloadNewsTask.INIT_DELAY, DownloadNewsTask.PERIOD);
            _log.info("Thread Manager is initialized");
        } catch (final Exception e) {
            _log.error("TMINIT: Caught exception ", e);
        }
    }

    /**
     * Cancel the timer and stop all active threads
     */
    public void destroy() {
        _newsDownloadTimer.cancel();
        stopAllThreads();
        _log.info("Thread Manager has been shut down");
    }

    private void stopAllThreads() {
        final Enumeration it = _createdThreads.elements();
        while (it.hasMoreElements()) {
            final Thread t = (Thread) it.nextElement();
            if (t.isAlive()) {
                _log.info("Thread " + t + " is alive.");
                t.stop();
                _log.info("Thread " + t + " has been stopped");
            } else {
                _log.info("Thread " + t + " is no longer alive");
            }
        }
    }
}
