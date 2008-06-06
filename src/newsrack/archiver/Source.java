package newsrack.archiver;

import newsrack.user.User;
import newsrack.database.NewsItem;
import newsrack.database.DB_Interface;
import newsrack.GlobalConstants;

import java.util.Collection;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The class <code>Source</code> represents a news source.
 * @author  Subramanya Sastry
 * @version 2.0 November 12, 2006
 */

public class Source implements java.io.Serializable
{
// ############### STATIC FIELDS AND METHODS ############
   	/* Logging output for this plug in instance. */
   protected static Log _log = LogFactory.getLog(Source.class);

	private static DB_Interface _db;

      // Read in a file that specifies for which feeds / domains,
      // cached text cannot be displayed!
   public static void init(DB_Interface db)
   {
		_db = db;
		Feed.init(db);
   }

	public static Source buildSource(User u, String utag, String name, String feedUrl)
	{
		if (_log.isDebugEnabled()) _log.debug("Request to build source: " + name + ", tag - " + utag);
		Source s = _db.getSource(u, utag);
		if (s == null)
			s = new Source(u, utag, name, feedUrl); // Create a new source object and record it

		return s;
	}

	public static NewsItem getNewsItemFromLocalCopyPath(String path)
	{
		return _db.getNewsItemFromLocalCopyPath(path);
	}

	public static void main(String[] args)
	{
      // NOTHING HERE anymore!
	}

// ############### NON-STATIC FIELDS AND METHODS ############
	/* 128 bytes for most news sources => 8 sources per KB => 8000 per MB RAM */

	private       Long   _key;		// DB key for this source
	private       User   _user;	// The user who created this source
	private       Feed   _feed;	// The feed that this source uses 
	public final  String _utag;	// A custom id assigned (by the user) to this source for easy reference
	public final  String _name;	// Name of this news source

      // Needed by the init method
   private Source() { _utag = ""; _name = ""; _feed = null; }

	protected Source(long key, String name, String tag)
	{
		_key = key;
		_utag = tag;
		_name = name;
	}

	private Source(User u, Feed f, String name, String utag)
	{
		_user = u;
		_utag = utag;
		_name = name.trim();
		_feed = f;
	}

	private Source(User u, String utag, String name, String rssFeed)
	{
		_user = u;
		_utag = utag;
		_name = name;
		_feed = (rssFeed == null) ? null : Feed.getFeed(rssFeed, _utag, name);
	}

	public void    setKey(Long k)  { _key = k; }
	public Long    getKey()        { return _key; }
	public void    setUser(User u) { _user = u; }
	public User    getUser()       { return _user; }
	public Long    getUserKey()    { return _user.getKey(); }
	public void    setFeed(Feed f) { _feed = f; }
	public Feed    getFeed()       { return _feed; }
	public String  getName()       { return _name; }
	public String  getTag()        { return _utag; }
   public boolean getCacheableFlag() { return _feed.getCacheableFlag(); }
   public boolean getCachedTextDisplayFlag() { return _feed.getCachedTextDisplayFlag(); }

	public String toString()
	{
		return "<" + getFeed().getTag() + ", "
		           + _name + ", "
		           + _utag + ", "
		           + ((getFeed().getUrl() == null) ? "none" : getFeed().getUrl()) + ">";
	}

	/**
	 * Read the source, store it locally, and download all the news items available
	 * with the source!  At this time, only RSS feed sources are supported.
	 */
	public Collection<NewsItem> readSource() throws Exception
	{
		if (_feed != null) {
			if (_log.isInfoEnabled()) _log.info("RSS source is: " + this);
			return _feed.readFeed();
		}
		else {
			if (_log.isErrorEnabled()) _log.error("Ignoring source " + this + ". It has no rss feed");
			return null;
		}
	}

	public Collection<NewsItem> getArchivedNews(String yStr, String mStr, String dStr)
	{
		return _db.getArchivedNews(this, yStr, mStr, dStr);
	}
}
