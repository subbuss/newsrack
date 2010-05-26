package newsrack.database.sql;

import java.io.File;
import java.io.PrintWriter;
import java.io.Reader;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import newsrack.archiver.Feed;
import newsrack.database.NewsItem;
import newsrack.filter.Category;
import newsrack.user.User;
import newsrack.util.IOUtils;
import newsrack.util.StringUtils;

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
   public static final ThreadLocal<SimpleDateFormat> DATE_PARSER = new ThreadLocal<SimpleDateFormat>() {
		protected SimpleDateFormat initialValue() { return new SimpleDateFormat("d.M.yyyy"); }
	};

   private static String getDateString(Date d)
   {
     	return DATE_PARSER.get().format(d);
   }

	private static String getValidFilePath(String pathPrefix, String pathSuffix, List<Long> feedKeys)
	{
		for (Long f: feedKeys) {
			String fullPath = pathPrefix + File.separator + SQL_DB._sqldb.getFeed(f).getTag() + File.separator + pathSuffix;
			if ((new File(fullPath)).isFile())
				return fullPath;
		}

		return null;
	}

	private static String getGlobalNewsArchive() { return SQL_DB._sqldb.getGlobalNewsArchive(); }

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
	// List<Category> _cats;			// Categories that this news item belongs to

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
	   String localCopyPath = getDateString() + File.separator + getFeed().getTag() + File.separator + _localCopyName;
		sb.append("\t\t<localcopy path=\"" + StringUtils.filterForXMLOutput(localCopyPath) + "\" />\n");
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
	public List<Category> getLeafCategories() { return SQL_DB._sqldb.getClassifiedCatsForNewsItem(this, true); }
	public List<Category> getAllCategories()  { return SQL_DB._sqldb.getClassifiedCatsForNewsItem(this, false); }
	public int     getNumCats()           { return getLeafCategories().size(); }
	public Long    getFeedKey()           { return _feedKey; }
	public Feed    getFeed()              { return SQL_DB._sqldb.getFeed(_feedKey); }
	public String  getLinkForCachedItem() { return _localCopyName + ":" + _nKey; }

	public SQL_NewsIndex getNewsIndex() 
	{ 
		if (_newsIndex == null)
			_newsIndex = SQL_DB._sqldb.getNewsIndex(_newsIndexKey);
			
		return _newsIndex;
	}

	private String getNewsItemPath(boolean wantOrig)
	{
			// Convert 12.11.2005 --> 2005/11/12/
		String[] dateStr = getDateString().split("\\.");
		String pathPrefix = getGlobalNewsArchive() + (wantOrig ? "orig" : "filtered") + File.separator + dateStr[2] + File.separator + dateStr[1] + File.separator + dateStr[0];

			// 1. FAST common case -- try with md5-hashed local name + feed passed in with the news item
		String localName = getLocalFileName();
		String fullPath = pathPrefix + File.separator + getFeed().getTag() + File.separator + localName;

			// 2. Didn't work .. check if this news item has been associated with other feeds
		if (!((new File(fullPath)).isFile())) {
			if (getKey() == null) {
				_log.error("NewsItem with url " + getURL() + " is not in the db!");
				return null;
			}

			List<Long> allFeedKeys = (List<Long>)SQL_Stmt.GET_ALL_FEEDS_FOR_NEWS_ITEM.get(getKey());
			fullPath = getValidFilePath(pathPrefix, localName, allFeedKeys);

				// 3. Check with local name stored in the db -- backward compatibility
				// IMPORTANT: Check this *before* checking with old-style naming because
				// there can be multiple news items with the same base file name!
				// Ex: http://.../index.html --> map to "index.html", "ni1.index.html", etc.
				//     Using base file name will return "index.html" for all these urls 
				//     which would be incorrect!
			if (fullPath == null)
				fullPath = getValidFilePath(pathPrefix, (String)SQL_Stmt.GET_NEWS_ITEM_LOCALNAME.get(getKey()), allFeedKeys);

				// 4. Check with old syle naming -- backward compatibility
			if (fullPath == null)
				fullPath = getValidFilePath(pathPrefix, StringUtils.getBaseFileName(getURL()), allFeedKeys);
		}

		return fullPath;
	}

		// BUGGY! This is no longer correct -- this is just a hangover from really old code.
		// Only getOrigFilePath() and getFilteredFilePath() are correct going forward!
   public File    getRelativeFilePath()  { return new File(SQL_DB._sqldb.getArchiveDir(getFeed(), getDate()) + getLocalFileName()); }

   public File    getOrigFilePath()
   {
		String p = getNewsItemPath(true);
		return (p == null) ? null : new File(p);
   }

   public File    getFilteredFilePath()
   { 
		String p = getNewsItemPath(false);
		return (p == null) ? null : new File(p);
   }

	public Reader  getReader() throws java.io.IOException 
	{ 
		String fullPath = getNewsItemPath(false);
        /* If body text is less than 512 bytes, assume it to be a non-text
           feed */
		if (fullPath != null) {
            if (new File(fullPath).length() < 512) {
                return new java.io.StringReader(this.getDescription());
            }
            else
                return IOUtils.getUTF8Reader(fullPath);
        }
		else
			throw new java.io.FileNotFoundException();
    }

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

	public void canonicalizeURL()
	{
		String oldUrl = getURL();
		String newUrl = newsrack.util.URLCanonicalizer.canonicalize(oldUrl);
		if (!newUrl.equals(oldUrl)) {
			String syncKey = newUrl.intern();
			synchronized(syncKey) {
				NewsItem dupe = getNewsItemFromURL(newUrl);
				if (dupe == null) {
						// No conflict with the new url!
					newsrack.util.Tuple<String,String> t = SQL_DB.splitURL(newUrl);
						// Update the url
					SQL_StmtExecutor.update("UPDATE news_items SET url_root = ?, url_tail = ? WHERE n_key = ?", 
					                        new SQL_ValType[] { SQL_ValType.STRING, SQL_ValType.STRING, SQL_ValType.LONG },
													new Object[] { t._a, t._b, getKey() });
						// Update the md5 hash
					SQL_StmtExecutor.update("UPDATE news_item_url_md5_hashes SET url_hash = md5(?) WHERE n_key = ?", 
					                        new SQL_ValType[] { SQL_ValType.STRING, SQL_ValType.LONG },
													new Object[] { newUrl, getKey() });

					System.out.println("Modified url from: " + oldUrl + " to " + newUrl);
				}
				else {
					File deletedFile = this.getFilteredFilePath();
						// News item already exists .. merge the two news items!
						// 1. Assign over all of this news item's category assignments to the dupe
					SQL_StmtExecutor.update("UPDATE IGNORE cat_news SET n_key = ? WHERE n_key = ?",
					                        new SQL_ValType[] { SQL_ValType.LONG, SQL_ValType.LONG },
													new Object[] { dupe.getKey(), getKey() });
						// 2. Assign over all of this news items's news collections assignments to the dupe
					SQL_StmtExecutor.update("UPDATE IGNORE news_collections SET n_key = ? WHERE n_key = ?",
					                        new SQL_ValType[] { SQL_ValType.LONG, SQL_ValType.LONG },
													new Object[] { dupe.getKey(), getKey() });
						// 3. Delete the news item now!
					SQL_StmtExecutor.delete("DELETE FROM news_items WHERE n_key = ?",
					                        new SQL_ValType[] { SQL_ValType.LONG },
													new Object[] { getKey() });

					System.out.println("please REMOVE: " + deletedFile);
					System.out.println("Modified url from: " + oldUrl + " to " + newUrl + " and deleted news item: " + getKey());
				}
			}
		}
		else {
			System.out.println("No change in url: " + oldUrl);
		}
	}
}
