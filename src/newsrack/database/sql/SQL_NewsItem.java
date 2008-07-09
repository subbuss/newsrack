package newsrack.database.sql;

import newsrack.database.NewsItem;
import newsrack.archiver.Feed;
import newsrack.filter.Category;
import newsrack.util.StringUtils;
import newsrack.user.User;

import java.io.File;
import java.io.Reader;
import java.io.PrintWriter;
import java.util.Date;
import java.util.List;
import java.text.SimpleDateFormat;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The class <code>SQL_NewsItem</code> represents a news item.
 * This could be a newspaper clipping, a magazine or journal article,
 * or, more generally anything that is relevant enough to be added
 * to the news archive.
 *
 * @author  Subramanya Sastry
 */

public class SQL_NewsItem extends NewsItem
{
      // Share the logging instance
   private static Log _log = LogFactory.getLog(SQL_DB.class);

	// Solution courtesy: http://publicobject.com/2006/05/simpledateformat-considered-harmful.html
   private static final ThreadLocal<SimpleDateFormat> DATE_PARSER = new ThreadLocal<SimpleDateFormat>() {
		protected SimpleDateFormat initialValue() { return new SimpleDateFormat("d.M.yyyy"); }
	};

   private static String getDateString(Date d)
   {
     	return DATE_PARSER.get().format(d);
   }

	Long    _nKey;				// Unique ID of this news item in the database
		// Split the URL into 2 parts: the root and the base
		// This is to save in-memory space.  The URL root tend to be few (based on the newspaper)
		// and the string object can be shared across news items thus saving space!
	String  _urlRoot;			// Root of the URL of the article
	String  _urlTail;			// Tail of the URL of the article
	String  _localCopyName;	// Name of the local copy
	String  _date;				// Date of publication
	String  _author;			// Author of the article
	String  _title;			// Title of the article
	String  _description;	// Description provided
	Long    _feedKey;			// DB key of the feed that this news item belongs to!
	Long           _newsIndexKey;	// Key of the news index that this news item belongs to
	SQL_NewsIndex  _newsIndex;		// news index that this news item belongs to
	List<Category> _cats;			// Categories that this news item belongs to

	private void init(String urlRoot, String urlTail, String baseName)
	{
		_nKey    = null;
		_urlRoot = urlRoot;
		_urlTail = urlTail;
			// At one point, the localcopy path had some relevance in terms of where the
			// news item was stored on disk.  But, now, that connection has been broken
			// Now, the local copy path serves as a shorthand for information about the news item
		_localCopyName = baseName;
	}

	public SQL_NewsItem(String url, Long feedKey, Date d)
	{
		String baseName = SQL_DB._sqldb.getBaseNameForArticle(url);
		newsrack.util.Tuple<String, String> t = SQL_DB.splitURL(url);
		init(t._a, t._b, baseName);
		_feedKey = feedKey;
		setDate(d);
	}

	public SQL_NewsItem(String urlRoot, String urlTail, String title, String desc, String author, Long feedKey, Date d)
	{
		String baseName = SQL_DB._sqldb.getBaseNameForArticle(urlRoot + urlTail);
		init(urlRoot, urlTail, baseName);
		setTitle(title);
		setDescription(desc);
		setDate(d);
		setAuthor(author);
		_feedKey = feedKey;
	}

	/** * URL used to generate hashcode */
	public int hashCode() { return getURL().hashCode(); }

	/** * URL is sufficient to check for equality!  */
	public boolean equals(Object o)
	{
		if ((o != null) && (o instanceof SQL_NewsItem)) {
			return getURL().equals(((SQL_NewsItem)o).getURL());
		}
		else {
			return false;
		}
	}

	/**
	 * This string does a xml-dump of the news item
	 */
	public String toString()
	{
		StringBuffer sb = new StringBuffer("\t<item>\n");
		sb.append("\t\t<feed key=\"" + _feedKey + "\" />\n");
		sb.append("\t\t<date val=\"" + getDateString() + "\" />\n");
		sb.append("\t\t<title val=\"" + StringUtils.filterForXMLOutput(_title) + "\" />\n");
		if (_author != null)
			sb.append("\t\t<author name=\"" + StringUtils.filterForXMLOutput(_author) + "\" />\n");
		if (_description != null)
			sb.append("\t\t<description val=\"" + StringUtils.filterForXMLOutput(_description) + "\" />\n");
		sb.append("\t\t<url val=\"" + StringUtils.filterForXMLOutput(getURL()) + "\" />\n");
		sb.append("\t\t<localcopy path=\"" + StringUtils.filterForXMLOutput(getLocalCopyPath()) + "\" />\n");
		sb.append("\t</item>\n");

		return sb.toString();
	}

	public void  setKey(Long k)           { _nKey = k; }
	public void  setTitle(String t)       { _title = t; }
	public void  setDate(Date d)          { _date = getDateString(d); }
	public void  setDate(String d)        { _date = d; } // Date of publication (in dd.mm.yyyy format)
	public void  setDescription(String d) { _description = d; }
	public void  setAuthor(String a)      { _author = a; }
	public void  setNewsIndexKey(Long idxKey)    { _newsIndexKey = idxKey; }
	public void  setNewsIndex(SQL_NewsIndex idx) { _newsIndex = idx; }
	public void  setURL(String u) 		
	{
		if (u != null) {
			int i = 1 + u.indexOf('/', 7);	// Ignore leading "http://"
			_urlRoot = u.substring(0, i);
			_urlTail = u.substring(i);
		}
	}

	public Long    getKey()         { return _nKey; }
	public boolean inTheDB()        { return _nKey != null; }
	public String  getTitle()       { return _title; }
	public String  getDateString()  { return _date; }
	public String  getAuthor()      { return _author; }
	public String  getDescription() { return _description; }
	public String  getURL()         { return _urlRoot + _urlTail; }
	public List<Category> getCategories() {
		if (_cats == null)
			_cats = SQL_DB._sqldb.getClassifiedCatsForNewsItem(this); 
		return _cats;
	}
	public int     getNumCats()       { return getCategories().size(); }
	public Long    getFeedKey()       { return _feedKey; }
	public Feed    getFeed()          { return SQL_DB._sqldb.getFeed(_feedKey); }
	public String  getLinkForCachedItem() { return _localCopyName + ":" + _nKey; }
	public String  getLocalCopyPath() { return getDateString() + File.separator + getFeed().getTag() + File.separator + _localCopyName; }
	public SQL_NewsIndex getNewsIndex() 
	{ 
		if (_newsIndex == null)
			_newsIndex = SQL_DB._sqldb.getNewsIndex(_newsIndexKey);
			
		return _newsIndex;
	}
	public Reader  getReader() throws Exception { return SQL_DB._sqldb.getNewsItemReader(this); }
	public Date    getDate()           	
	{ 
		try { 
			return DATE_PARSER.get().parse(_date);
		} 
		catch (Exception e) { 
			_log.error("EXCEPTION parsing date " + _date + " for news item with url " + getURL(), e);
			return new Date();
		}
	}

      /** Can the cached text of this news item be displayed?  */
   public boolean getDisplayCachedTextFlag()
   {
      if (_feedKey == null) {
         _log.error("Feed key null for news item with sql key " + _nKey);
         return false;
      }
      else {
			return getFeed().getCachedTextDisplayFlag();
      }
   }

	public String getSourceNameForUser(User u)
	{
		if (_feedKey != null) {
			return SQL_DB._sqldb.getSourceName(_feedKey, u.getKey());
		}
		else {
         _log.error("Feed key null for news item with sql key " + _nKey);
			return "";
		}
	}

	public void printCategories(PrintWriter pw) { /* nothing to do for now */ }

		// Access only to classes in this package
	String  getLocalFileName() { return _localCopyName; }

	void copy(SQL_NewsItem ni)
	{
		this._nKey          = ni._nKey;
		this._localCopyName = ni._localCopyName;
		this._newsIndexKey  = ni._newsIndexKey;
		this._newsIndex     = ni._newsIndex;
		this._feedKey       = ni._feedKey;
	   this._urlRoot       = ni._urlRoot;
	   this._urlTail       = ni._urlTail;
	   this._date          = ni._date;
	   this._author        = ni._author;
	   this._title         = ni._title;
	   this._description   = ni._description;
	}
}
