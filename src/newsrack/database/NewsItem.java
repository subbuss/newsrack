package newsrack.database;

import java.io.File;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.Reader;
import java.net.URL;
import java.util.Date;
import java.util.List;

import newsrack.NewsRack;
import newsrack.archiver.Feed;
import newsrack.archiver.HTMLFilter;
import newsrack.filter.Category;
import newsrack.user.User;
import newsrack.util.IOUtils;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The class <code>NewsItem</code> represents a news item.
 * This could be a newspaper clipping, a magazine or journal article,
 * or, more generally anything that is relevant enough to be added
 * to the news archive.
 *
 * @author  Subramanya Sastry
 * @version 1.0 23/05/2004
 */
abstract public class NewsItem implements java.io.Serializable {
	public static NewsItem getNewsItemFromURL(String url) {
		return NewsRack.getDBInterface().getNewsItemFromURL(url);
	}

   	// Logging output for this class
   static Log _log = LogFactory.getLog(NewsItem.class);

	abstract public Long     getKey();
	abstract public String   getURL();
   /** Returns the feed that this news item belogs to */
   abstract public Feed     getFeed();
   abstract public Long     getFeedKey();
	abstract public String   getTitle();
	abstract public NewsIndex getNewsIndex();
	/** Returns the date on which this news item was published */
	abstract public Date     getDate();
	/** Returns the d.m.yyyy representation of the on which this news item was published */
	abstract public String   getDateString();
	abstract public String   getAuthor();
	abstract public String   getDescription();
	abstract public String   getLinkForCachedItem();
   abstract public File     getRelativeFilePath();
   abstract public File     getOrigFilePath();
   abstract public File     getFilteredFilePath();
	/** Returns a reader object to read the contents of the news item */
	abstract public Reader   getReader() throws java.io.IOException;
	abstract public int      getNumCats();
	abstract public List<Category> getLeafCategories();
	abstract public List<Category> getAllCategories();
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

	public boolean olderThan(NewsItem n) {
		return getDate().before(n.getDate());
	}

	public int compareTo(NewsItem n) {
		return getDate().compareTo(n.getDate());
	}

   public boolean download(DB_Interface dbi) throws Exception {
      PrintWriter filtPw = IOUtils.getUTF8Writer(dbi.getOutputStreamForFilteredArticle(this));
		OutputStream origOS = dbi.getOutputStreamForOrigArticle(this);
      String url = getURL();
      try {
         if ((filtPw != null) && (origOS != null)) {
            boolean done = false;
            int numTries = 0;
				int MAX_RETRIES = 3;
            do {
               numTries++;

					IOUtils.copyInputToOutput(IOUtils.getURLInputStream(new URL(url), MAX_RETRIES), origOS, true);
					File origFile = getOrigFilePath();

					// Null or small file lengths implies there was an error downloading the url
					if (origFile.length() > 100) {
						(new HTMLFilter(url, origFile, filtPw)).run();

                  done = true;

						filtPw.flush();
						File filtFile = getFilteredFilePath();
						long len = filtFile.length();
						if (len < 900) {
                  	_log.info("For file with path " + filtFile.getPath() + ", filtered file length is " + len + ".");
						}
               } else {
						// Delete the files so they can be fetched afresh!
						if ((origFile != null) && origFile.exists()) {
							if (!origFile.delete()) {
								_log.error("Could not delete file " + origFile);
							}
						}
						File filtFile = getFilteredFilePath();
						if ((filtFile != null) && filtFile.exists()) {
							if (!filtFile.delete()) {
								_log.error("Could not delete file " + filtFile);
							}
						}

                  _log.info("Error downloading from url: " + url + " Retrying (max 3 times) once more after 5 seconds!");
                  newsrack.util.StringUtils.sleep(5);
               }
            } while (!done && (numTries < MAX_RETRIES));
         } else {
            _log.info("Ignoring! There already exists a downloaded file for url: " + url);
         }
      } catch (Exception e) {
            // Delete the file for this article -- otherwise, it will
            // trigger a false hit in the archive later on!
         if (filtPw != null) dbi.deleteFilteredArticle(this);

         throw e;
      } finally {
            // close the files -- ignore any resulting exceptions
         try { if (origOS != null) origOS.close(); } catch(Exception e) {}
         try { if (filtPw != null) filtPw.close(); } catch(Exception e) {}
      }

      // After a download, sleep for 1 second to prevent bombarding the remote server with downloads
      newsrack.util.StringUtils.sleep(1);

      // Clear the cookie jar after each download so that you get fresh cookies for each article
		// HTMLFilter.clearCookieJar();

		// We succeeded if the filtered file exists
		return (getFilteredFilePath().exists());
   }
}
