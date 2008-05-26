package newsrack.database;

import newsrack.GlobalConstants;
import newsrack.archiver.Feed;
import newsrack.user.User;
import newsrack.filter.Category;

import java.io.Reader;
import java.io.PrintWriter;
import java.lang.String;
import java.util.Date;
import java.util.List;

/**
 * The class <code>NewsItem</code> represents a news item.
 * This could be a newspaper clipping, a magazine or journal article,
 * or, more generally anything that is relevant enough to be added
 * to the news archive.
 *
 * @author  Subramanya Sastry
 * @version 1.0 23/05/04
 */

abstract public class NewsItem
{
	abstract public Long     getKey();
	abstract public String   getURL();
   /** Returns the feed that this news item belogs to */
   abstract public Feed     getFeed();
   abstract public Long     getFeedKey();
	abstract public String   getTitle();
	/** Returns the date on which this news item was published */
	abstract public Date     getDate();
	/** Returns the d.m.yyyy representation of the on which this news item was published */
	abstract public String   getDateString();
	abstract public String   getAuthor();
	abstract public String   getDescription();
	abstract public String   getLocalCopyName();	// File name for the local copy
	abstract public String   getLocalCopyPath();	// Full path for the local copy
	/** Returns a reader object to read the contents of the news item */
	abstract public Reader   getReader() throws Exception;
	abstract public int      getNumCats();
	abstract public List     getCategories();
   /** Can the cached text of this news item be displayed?  */
   abstract public boolean  getDisplayCachedTextFlag();
	abstract public String   getSourceNameForUser(User u);
	abstract public void     printCategories(PrintWriter pw);
	abstract public void     setKey(Long n);
	abstract public void     setTitle(String t);
	abstract public void     setDate(Date d);
	/** Date of publication (in dd.mm.yyyy format) */
	abstract	public void     setDate(String d);
	abstract public void     setDescription(String d);
	abstract public void     setAuthor(String a);
	abstract public void     setURL(String u);
	abstract public void     setLocalCopyName(String p);

	public boolean olderThan(NewsItem n)
	{
		return getDate().before(n.getDate());
	}

	public int compareTo(NewsItem n)
	{
		return getDate().compareTo(n.getDate());
	}
}
