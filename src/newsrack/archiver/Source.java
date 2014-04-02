package newsrack.archiver;

import java.util.Collection;

import newsrack.database.DB_Interface;
import newsrack.database.NewsItem;
import newsrack.user.User;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The class <code>Source</code> represents a news source.
 * @author  Subramanya Sastry
 * @version 2.0 November 12, 2006
 */

public class Source implements java.io.Serializable
{
	static private class SourceComparator implements java.util.Comparator
	{
		public int compare(Object o1, Object o2)
		{
			Source s1 = (Source)o1;
			Source s2 = (Source)o2;

				// Handle the equals case first
			if (s1._key.equals(s2._key))
				return 0;

			int x = s1._name.compareTo(s2._name);
			return (x != 0) ? x : ((s1._key < s2._key) ? -1 : 1);
		}
	}

// ############### STATIC FIELDS AND METHODS ############
   	/* Logging output for this plug in instance. */
   protected static Log _log = LogFactory.getLog(Source.class);

	public final static java.util.Comparator sourceComparator = new SourceComparator();

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
		Feed f = null;
		if (utag == null) {
			f = Feed.getFeed(feedUrl, null, name);
			utag = f.getTag();
		}

		Source s = _db.getSource(u, utag);
		if (s == null) {
			if (name == null) {
				if (f == null)
					f = Feed.getFeed(feedUrl, utag, name);
				name = f.getName();
			}
			s = new Source(u, utag, name, feedUrl);
		}

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

	private Source(User u, String utag, String name, String rssFeed)
	{
		_user = u;
		_utag = utag;
		_name = name;
		_key  = null;
		_feed = (rssFeed == null) ? null : Feed.getFeed(rssFeed, _utag, name);
			// FIXME:
		if (_feed == null)
			_log.error("ERROR: No feed for source with tag: " + _utag);
	}

	public int hashCode() { return _feed.hashCode()*31 + _utag.hashCode()*31 + _user.getUid().hashCode()*31; }

	public boolean equals(Object o) {
		if (o instanceof Source) {
			Source s = (Source)o;
				// Won't consider source name OR source keys in this equation!
			return (s._feed == _feed) && s._utag.equals(_utag) && s._user.getUid().equals(_user.getUid());
		}
		else {
			return false;
		}
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
	public Collection<NewsItem> read() throws Exception
	{
		if (_feed != null) {
			if (_log.isInfoEnabled()) _log.info("RSS source is: " + this);
			_feed.download();
			return _feed.getDownloadedNews();
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
