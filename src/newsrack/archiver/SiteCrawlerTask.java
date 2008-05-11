package newsrack.archiver;

import java.io.File;
import java.io.FileInputStream;
import java.util.Date;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.Hashtable;
import java.util.Timer;
import java.util.TimerTask;
import java.util.Properties;
import newsrack.GlobalConstants;
import newsrack.util.ProcessReader;
import newsrack.util.ThreadManager;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * class <code>SiteCrawlerTask</code> implements the functionality
 * of firing crawlers (site-specific or generic) to crawl those sites
 * and do their thing (either generate a RSS feed, or download news
 * and create appropriate index files).
 */
public class SiteCrawlerTask extends TimerTask
{
   	// Logging output for this class
   private static Log _log = LogFactory.getLog(SiteCrawlerTask.class);

		// Number of milliseconds in an hour and a day
	public static long ONE_HOUR = 60*60*1000;
	public static long ONE_DAY  = 24*ONE_HOUR;

		// Keep track of when a crawler was last run for a particular site
	private static final Hashtable _crawledTimes = new Hashtable();

	private static File          _crawlersFile = null;
	private static long          _lastReadTime = 0;
	private static Timer         _timer        = null;
	private static ThreadManager _tm           = null;

	public static boolean checkCrawlersFile()
	{
			// Check if the file of registered crawlers have been modified since
			// the last time it has been read!  If so, cancel all scheduled tasks
			// and reschedule the site-crawler and download tasks
		if (_crawlersFile.lastModified() > _lastReadTime) {
			if (_log.isInfoEnabled()) _log.info("Crawlers file modified since last read ... RE-INITIALIZING ...");
			_timer.cancel(); 	// Cancel all scheduled tasks
			_tm.initialize(_crawlersFile);
			return true;
		} else
			return false;
	}

	public static void registerSiteCrawlers(final ThreadManager tm, final Timer t, final File crawlersFile)
	{
		if (!crawlersFile.exists())
			return;

		_crawlersFile = crawlersFile;
		_timer        = t;
		_tm           = tm;

			// Set the time when this file was last read!
			// If the file is modified after this, the file will be read again!
		_lastReadTime = (new Date()).getTime();

			// Get a date object set to 6 am -- this is the default time
			// for running site crawlers
		final GregorianCalendar cal = new GregorianCalendar();	
		cal.set(Calendar.HOUR_OF_DAY, 6);
		cal.set(Calendar.MINUTE, 0);
		final Date d6am = cal.getTime();

		try {
			final Properties crawlers = new Properties();
			crawlers.load(new FileInputStream(crawlersFile));
			final java.util.Enumeration cList = crawlers.propertyNames();

			boolean runFutureOnly = false;
			final String skipOlderCrawls = crawlers.getProperty("skip.older.crawls");
			if ((skipOlderCrawls != null) && skipOlderCrawls.equals("true"))
				runFutureOnly = true;

			while (cList.hasMoreElements()) {
				final String cName = (String)cList.nextElement();
				if (cName.endsWith("TIMES"))
					continue;

				final String cPath = crawlers.getProperty(cName);
					// Read in the crawler name!
				if (cPath.indexOf(File.separator) != -1) {
					final String errMsg = "Cannot have '" + File.separator + "' in crawler path.  IGNORING crawler " + cName;
					if (_log.isErrorEnabled()) _log.error(errMsg);
					crawlers.remove(cName);
				}
				else {
					if (_log.isInfoEnabled()) _log.info("READ Crawler " + cName + " with path " + cPath);
						// Read in the crawler times
						// - If provided, schedule at the hours specified in the file
						// - Else, schedule crawler to run at 6 am!
					final String cTimes = crawlers.getProperty(cName + ".TIMES");
					if (cTimes != null)
						try {
								// CATCH any errors before attempting to schedule
								// the crawler task!
							String[] times = cTimes.split("[ \t]");
							for (int i = 0; i < times.length; i++)
								if (times[i].equals(""))
									continue;
								else
									Integer.parseInt(times[i]);

								// Now that we have gotten here without any exceptions,
								// go ahead and schedule the crawlers at the specified times!
							times = cTimes.split("[ \t]");
							for (int i = 0; i < times.length; i++) {
								if (times[i].equals(""))
									continue;

									// Get a date object and schedule the task
								cal.set(Calendar.HOUR_OF_DAY, Integer.parseInt(times[i]));
								final Date d = cal.getTime();
								t.scheduleAtFixedRate(new SiteCrawlerTask(cName, cPath, d), d, ONE_DAY);
							}
						}
						catch (final NumberFormatException nfe) {
							if (_log.isErrorEnabled()) _log.error("Invalid time string " + cTimes + " for crawler " + cName);
						}
					else
						t.scheduleAtFixedRate(new SiteCrawlerTask(cName, cPath, d6am), d6am, ONE_DAY);

						// Indicate that the crawlers have already been run at the time of start up!
					if (runFutureOnly)
						_crawledTimes.put(cName, new Date());
				}
			}
		}
		catch (final java.io.IOException e) {
			System.err.println("Exception while loading crawlers file: " + crawlersFile);
			System.err.println(e.toString());
			e.printStackTrace();
		}
	}

	private String _name;	// What crawler does this object represent?
	private String _path;	// Where does the crawler reside?
	private Date   _time;	// When should this site crawler run?

	public SiteCrawlerTask(final String name, final String path, final Date time)
	{
		_name = name;
		_path = path;
		_time = time;
		if (_log.isInfoEnabled()) _log.info("New crawler <" + name + "> with path <" + path + "> scheduled at time <" + time + ">");
	}

	/** Runs the site crawler task -- the site-specific crawlers are 
	 *  run for all registered crawlers */
	public void run()
	{
			// Check if the site crawlers file has been modified 
			// since last read.  If so, cancel all tasks and reschedule!
		if (SiteCrawlerTask.checkCrawlersFile())
			return;

         // Record the thread with the thread manager!
      ThreadManager.recordThread(Thread.currentThread());

		final Date   nowTime  = new Date();
		final String cName    = _name;
		final String cPath    = _path;
		final String cDir     = GlobalConstants.getWebappPath() + File.separator + GlobalConstants.getProperty("crawlers.home");
		final String fullPath = cDir + File.separator + cPath;

		if (_log.isInfoEnabled()) {
         _log.info("---------------------------------------------------------");
		   _log.info("SCT: Running crawler " + cName + " with path " + cPath + " and fullpath - " + fullPath);
		   _log.info("SCT: Called at time " + nowTime);
      }

			// Check if we crawled the site just recently! (within an hour)
		final Date   lastRunTime = (Date)_crawledTimes.get(_name);
		if (lastRunTime != null) {
			final long lrt = lastRunTime.getTime();
			final long now = nowTime.getTime();
			if ((now - lrt) < ONE_HOUR) {
				if (_log.isInfoEnabled()) _log.info("We last crawled only " + (now - lrt)/(1000*60) + " minutes ago!  Skipping this time!");
            ThreadManager.removeThread(Thread.currentThread()); // Remove the thread from the thread manager!
				return;
			}
		}

			// Set the last crawled time
		_crawledTimes.put(_name, nowTime);

			/* Run the crawler, read the stdout and stderr streams 
			 * (which are simply sent to System.out -- FIXME --),
			 * wait for the crawler to return and exit */
		try {
		   Process cProc = Runtime.getRuntime().exec(fullPath);
			try {
				(new ProcessReader("stdout", fullPath, cProc.getInputStream(), System.out)).start();
				(new ProcessReader("stderr", fullPath, cProc.getErrorStream(), System.err)).start();
				if (cProc.waitFor() != 0)
					if (_log.isInfoEnabled()) _log.info(cPath + ": Got a non-zero exit status!");
			}
			catch (final Exception e) {
				if (_log.isErrorEnabled()) _log.error("ERROR running crawler " + cPath + ": " + e);
				e.printStackTrace();
			}
		}
		catch (final Exception e) {
			if (_log.isErrorEnabled()) _log.error("ERROR invoking crawler " + cPath + ": " + e);
			e.printStackTrace();
		}
		if (_log.isInfoEnabled()) _log.info("---------------------------------------------------------");

         // Remove the thread from the thread manager!
      ThreadManager.removeThread(Thread.currentThread());
	}
}
