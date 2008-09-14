package newsrack.database.sql.scripts;

import java.util.Collection;
import java.util.List;
import java.util.Date;
import java.io.File;

import newsrack.NewsRack;
import newsrack.database.DB_Interface;
import newsrack.database.NewsIndex;
import newsrack.database.NewsItem;
import newsrack.database.sql.SQL_NewsItem;
import newsrack.database.sql.SQL_NewsIndex;
import newsrack.database.sql.SQL_ValType;
import newsrack.database.sql.SQL_Stmt;
import newsrack.database.sql.SQL_StmtExecutor;
import newsrack.user.User;
import newsrack.filter.Issue;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class FixupTools
{
   private static Log _log = LogFactory.getLog((new FixupTools()).getClass());

	private static DB_Interface _db;

	public static void findNewsItemsWithMissingFiles(long newsIndexKey)
	{
		NewsIndex            ni   = _db.getNewsIndex(newsIndexKey);
		Collection<NewsItem> news = _db.getArchivedNews(ni);
      StringBuffer         buf  = new StringBuffer();
		for (NewsItem n: news) {
			try {
				n.getReader().close();
			}
			catch (java.io.FileNotFoundException e) {
            buf.append(n.getKey()).append(", ");
			}
			catch (Exception e) {
				System.out.println("Exception: " + e + " for news item: " + n.getKey());
			}
		}

      buf.append("-1");

      System.out.println("select count(*) from news_collections where ni_key = " + newsIndexKey + ";");
      System.out.println("select count(*) from cat_news where n_key in (" + buf + ");");
      System.out.println("delete from news_collections where n_key in (" + buf + ");");
      System.out.println("delete from news_items where n_key in (" + buf + ");");
      System.out.println("delete from news_item_url_md5_hashes where n_key in (" + buf + ");");
      System.out.println("delete from cat_news where n_key in (" + buf + ");");
	}

   public static void changeNewsIndexDate(long niKey, Date newDate)
   {
		((SQL_NewsIndex)_db.getNewsIndex(niKey)).changeDate(newDate);
/**
      Date      origDate = ni.getCreationTime();

		SQL_StmtExecutor.update("UPDATE news_indexes SET created_at = ? WHERE ni_key = ?",
		                        new SQL_ValType[] { SQL_ValType.DATE, SQL_ValType.LONG },
										new Object[] { newDate, niKey });
		SQL_StmtExecutor.update("UPDATE cat_news SET date_stamp = ? WHERE ni_key = ?",
		                        new SQL_ValType[] { SQL_ValType.DATE, SQL_ValType.LONG },
										new Object[] { newDate, niKey });

		Collection<NewsItem> news = _db.getArchivedNews(ni);

		for (NewsItem n: news) {
         File origorig = ((SQL_NewsItem)n).getOrigFilePath();
         File origfilt = ((SQL_NewsItem)n).getFilteredFilePath();
         n.setDate(newDate);
         File neworig = ((SQL_NewsItem)n).getOrigFilePath();
         File newfilt = ((SQL_NewsItem)n).getFilteredFilePath();

         //System.out.println("ORIG: For news item: " + n.getKey() + "; ORIG: " + origorig + "; NEW: " + neworig);
         //System.out.println("FILT: For news item: " + n.getKey() + "; ORIG: " + origfilt + "; NEW: " + newfilt);
      }
**/
   }

	public static void updateCountsForAllIssues()
	{
      List<Issue> issues = User.getAllValidatedIssues();
		for (Issue i: issues) {
			i.storeNewsToArchive();
		}
	}

	public static void main(String[] args) throws Exception
	{
		if (args.length < 2) {
			System.out.println("Usage: java newsrack.database.sql.scripts.FixupTools <properties-file> <action> [<other-optional-args>]");
			System.exit(0);
		}

   	String appPropertiesFile = args[0];
		String action = args[1];

		System.out.println("Properties file: " + appPropertiesFile);
		NewsRack.startup(null, appPropertiesFile);
      _db = NewsRack.getDBInterface();

      if (action.equals("update-counts")) {
	      updateCountsForAllIssues();
      }
      else if (action.equals("find-newsitems-without-files")) {
	      findNewsItemsWithMissingFiles(Long.parseLong(args[2]));
      }
      else if (action.equals("change-newsindex-date")) {
	      changeNewsIndexDate(Long.parseLong(args[2]), newsrack.database.sql.SQL_NewsItem.DATE_PARSER.get().parse(args[3]));
      }
      else {
         System.out.println("Unknown action: " + action);
      }

      System.out.println("\n -- DONE --");
      System.out.flush();
	}
}
