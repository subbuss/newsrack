package newsrack.database.sql;

import java.sql.Date;
import java.io.File;

import java.util.Collection;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import newsrack.database.NewsItem;
import newsrack.database.NewsIndex;
import newsrack.database.sql.SQL_DB;
import newsrack.database.sql.SQL_ValType;
import newsrack.database.sql.SQL_StmtExecutor;

import newsrack.archiver.Feed;

public class SQL_NewsIndex extends NewsIndex
{
   private static Log _log = LogFactory.getLog(SQL_NewsIndex.class);

	private Long _niKey;
	private Long _feedKey;
	private Date _createdAt;

	public SQL_NewsIndex(Long key) { _niKey = key; }
	public SQL_NewsIndex(Long key, Date t) { _niKey = key; _createdAt = t; }
	public SQL_NewsIndex(Long key, Long feedKey, Date d) { _niKey = key; _feedKey = feedKey; _createdAt = d; }

	public Feed getFeed()         { return SQL_DB._sqldb.getFeed(_feedKey); }
	public Date getCreationTime() { return _createdAt; }

	public Long   getKey()        { return _niKey; }
	public Long   getFeedKey()    { return _feedKey; }

   public void changeDate(java.util.Date newDate)
   {
         // Move all news items in this collection to their new destination in the archive
		Collection<NewsItem> news = SQL_DB._sqldb.getArchivedNews(this);
		for (NewsItem n: news) {
         File origOrig = ((SQL_NewsItem)n).getOrigFilePath();
         File origFilt = ((SQL_NewsItem)n).getFilteredFilePath();

         n.setDate(newDate);

         File newOrig = ((SQL_NewsItem)n).getOrigFilePath();
         File newFilt = ((SQL_NewsItem)n).getFilteredFilePath();

         System.out.println("ORIG: For news item: " + n.getKey() + "; RENAMING: " + origOrig + "; TO: " + newOrig);
         System.out.println("FILT: For news item: " + n.getKey() + "; RENAMING: " + origFilt + "; TO: " + newFilt);

         if (!origOrig.renameTo(newOrig))
           _log.error("Renaming from " + origOrig + " to " + newOrig + " failed for news item " + n.getKey());
         if (!origFilt.renameTo(newFilt))
           _log.error("Renaming from " + origFilt + " to " + newFilt + " failed for news item " + n.getKey());
      }

         // Update index and cat_news values
      SQL_ValType[] valTypes = new SQL_ValType[] { SQL_ValType.DATE, SQL_ValType.LONG };
      Object[]      args     = new Object[]      { new java.sql.Date(newDate.getTime()), _niKey };

		SQL_StmtExecutor.update("UPDATE news_indexes SET created_at = ? WHERE ni_key = ?", valTypes, args);
		SQL_StmtExecutor.update("UPDATE cat_news SET date_stamp = ? WHERE ni_key = ?", valTypes, args);
   }
}
