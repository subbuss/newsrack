package newsrack;

import newsrack.util.IOUtils;
import newsrack.database.DB_Interface;

import java.io.File;
import java.io.FileInputStream;
import java.text.SimpleDateFormat;
import java.util.Properties;
import javax.servlet.ServletContext;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * class <code>GlobalConstants</code> records system information
 * that is needed by the rest of the code, like paths, property values, etc.
 *
 * @author Subramanya Sastry
 */
public final class GlobalConstants
{
		// DUMMY
	private GlobalConstants() { }

	private static boolean 		 _initialized;
	private static String 		 _serverURL;
	private static String 		 _webappPath;
	private static DB_Interface _db;
	private static String 		 _globalNewsArchive;
	private static String 		 _resourcesFile;
	private static Properties   _nrProps = new Properties();

   	/* Logging output for this plug in instance. */
   private static Log _log = LogFactory.getLog((new GlobalConstants()).getClass());

	public static void loadDefaultProperties()
	{
		_nrProps.put("java.compiler", "javac");
		_nrProps.put("dtdDir", "dtds/");
		_nrProps.put("rssDir", "rss/");
		_nrProps.put("rssfeedName", "rss.xml");
		_nrProps.put("crawlers.home", "WEB-INF/crawlers/");
		_nrProps.put("dbInterface", "newsrack.database.ffdb.FlatFileDB_Interface");
		_nrProps.put("flatfiledb.userHome", "users/");
		_nrProps.put("flatfiledb.archiveHome", "global.news.archive/");
		_nrProps.put("flatfiledb.newsCache", "cache.xml");
		_nrProps.put("flatfiledb.newsCache.digesterRules", "cache.digester.rules.xml");
		_nrProps.put("flatfiledb.userTable", "user.table.xml");
		_nrProps.put("flatfiledb.userTable.digesterRules", "usertable.digester.rules.xml");
		_nrProps.put("flatfiledb.newsListing", "news.xml");
		_nrProps.put("flatfiledb.newsListing.digesterRules", "news.digester.rules.xml");
		_nrProps.put("flatfiledb.userInfoDir", "info/");
		_nrProps.put("flatfiledb.userIssuesDir", "issues/");
		_globalNewsArchive = getProperty("flatfiledb.globalArchive");

			// Set default system properties for networking.
			// Works only since JDK 1.4
			// 30 seconds connect and read timeout
		java.lang.System.setProperty("sun.net.client.defaultConnectTimeout", "30000");
		java.lang.System.setProperty("sun.net.client.defaultReadTimeout", "30000");

		_log.info("Loaded default properties");
	}

	public static void loadGlobalProperties()
	{
		loadProperties(_resourcesFile);

			/* Load override properties: things like user name, password, etc. which shouldn't be 
			 * stored in the main properties file and checked in svn/cvs (unless you happen to be me!) */
		loadProperties(_resourcesFile + ".override");
	}

	private static void loadProperties(String propertiesFile)
	{
		try {
			_nrProps.load((new GlobalConstants()).getClass().getClassLoader().getResourceAsStream(propertiesFile));
			java.util.Enumeration props = _nrProps.propertyNames();
			while (props.hasMoreElements()) {
				String pName = (String)props.nextElement();
				_log.info(pName + " = " + _nrProps.getProperty(pName));
			}
		}
		catch (java.io.IOException e) {
			_log.error("Exception while loading properties file: " + propertiesFile);
			_log.error(e.toString());
			e.printStackTrace();
		}
		_globalNewsArchive = getProperty("flatfiledb.globalArchive");
	}

	/** The string used to store user information in the session */
	public static final String USER_KEY = "user";

	/** The string used to store user id information in the session */
	public static final String UID_KEY  = "uid";

	public static final SimpleDateFormat DF = new SimpleDateFormat("MMM dd yyyy kk:mm z");

	public static void startup(ServletContext sc, String resourcesFile)
	{
		_log.info("ENTERED INIT: initialized - " + _initialized);
		if (_initialized) {
			_log.error("Newsrack already initialized! Cannot initialize again!");
			return;
		}

		if (sc != null) {
			_serverURL  = sc.getInitParameter("server-url");
			_webappPath = sc.getRealPath("");
		}
		else {
			_log.error("Servlet context is null!");
		}

		_log.info("Server URL  - " + _serverURL);
		_log.info("webapp path - " + _webappPath);

			// First, load default properties
		loadDefaultProperties();

			// Load properties file.  Properties defined here will override defaults
		_resourcesFile = resourcesFile;
		loadGlobalProperties();

			// Create the base RSS directory
		IOUtils.createDir(getBaseRssDir());

			// Try loading the database interface
		try {
			Class dbInterface = Class.forName(getProperty("dbInterface"));
			java.lang.reflect.Method m  = dbInterface.getMethod("getInstance", (java.lang.Class[])null);
			_db = (DB_Interface)m.invoke(null, (java.lang.Object [])null);
		}
		catch (Exception e) {
			_log.error("Error loading database!", e);
			_log.error("CAUSE: ", e);
		}
		_db.init();
		_globalNewsArchive = _db.getGlobalNewsArchive();
      newsrack.util.MailUtils.init();
      newsrack.util.PasswordService.init();
      newsrack.filter.NR_Collection.init(_db);
		newsrack.filter.Issue.init(_db);
		newsrack.filter.Category.init(_db);
      newsrack.user.User.init(_db);
		newsrack.archiver.Source.init(_db);
		_db.loadUserTable();

		_initialized = true;
	}

	protected static void shutdown()
	{
		_db.shutdown();
	}

	/** Returns the server URL of this newsrack installation */
	public static String getServerURL() { return _serverURL; }

	/** Returns the location of the global news archive */
	public static String getGlobalNewsArchive() { return _globalNewsArchive; }

	/** Returns the full path of the webapp */
	public static String getWebappPath() { return _webappPath; }

	public static DB_Interface getDBInterface() { return _db; }

	/** Gets the property value for a named property
	 *  @param pname Property whose value is requested
	 *  @return the requested property value
	 */ 
	public static String getProperty(String pname) { return _nrProps.getProperty(pname); }

	public static void setProperty(String name, String value)
	{
		_nrProps.setProperty(name, value);
	}

	public static String getDirPathProperty(String pname)
	{
		String v = getProperty(pname);
		if (!v.endsWith(File.separator))
			v += File.separator;
		return v;
	}

	/** Checks is the property value is set to true
	 *  @param pname Property whose value is being checked
	 *  @return true if the property is set to "true", false otherwise
	 */ 
   public static boolean isTrue(String pname)
   {
      String p = _nrProps.getProperty(pname);
      return ((p != null) && (p.compareToIgnoreCase("true") == 0));
   }

	/** Checks is the property value is set to false
	 *  @param pname Property whose value is being checked
	 *  @return true if the property is set to "false", false otherwise
	 */ 
   public static boolean isFalse(String pname)
   {
      String p = _nrProps.getProperty(pname);
      return ((p != null) && (p.compareToIgnoreCase("false") == 0));
   }

	/** Returns the base directory for where RSS feed files are stored */ 
	public static String getBaseRssDir() { return _webappPath + File.separator + getDirPathProperty("rssDir"); }

	public static boolean testing() { return isTrue("testing"); }

	public static boolean inDebugMode() { return isTrue("debugging"); }
}
