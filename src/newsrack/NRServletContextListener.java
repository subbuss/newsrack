package newsrack;

import javax.servlet.ServletContextListener;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContext;

import java.io.File;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import newsrack.GlobalConstants;
import newsrack.util.ThreadManager;

/**
 * class <code>NRServletContextListener</code> is the main entry point for the News Rack Application.
 *
 * @author Subramanya Sastry
 */
public class NRServletContextListener implements ServletContextListener
{
   public final static String APP_PROPERTIES_FILE = "newsrack.properties";
   public final static String CRAWLERS_FILE       = "registered.crawlers";

   private ServletContext _context;
	private ThreadManager  _tm;

	/** Has NewsRack been initialized? **/
	private static boolean _initialized = false;

   /* Logging output for this plug in instance. */
   private Log log = LogFactory.getLog(this.getClass());

   public void contextDestroyed(ServletContextEvent event)
   {
      _context = null;
		_tm.destroy();
		GlobalConstants.shutdown();
		log.info("News rack has been shut down");
   }
  
   public void contextInitialized(ServletContextEvent event)
   {
		try {
			_initialized = false;
			_context = event.getServletContext();
			GlobalConstants.startup(_context, APP_PROPERTIES_FILE);
			_tm = new ThreadManager();
			_tm.initialize(new File(GlobalConstants.getWebappPath() + File.separator + "WEB-INF" + File.separator + "classes" + File.separator + CRAWLERS_FILE));
			_initialized = true;
		}
		catch (Exception e) {
			log.error("NRINIT: caught exception!", e);
		}
		log.info("News rack is initialized");
   }
}
