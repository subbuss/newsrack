package newsrack.database.sql.scripts;

import java.util.Collection;
import java.util.List;
import java.util.ArrayList;
import java.util.Date;
import java.io.File;
import java.io.PrintWriter;
import java.io.BufferedReader;

import newsrack.NewsRack;
import newsrack.database.DB_Interface;
import newsrack.database.NewsIndex;
import newsrack.database.NewsItem;
import newsrack.database.sql.SQL_NewsItem;
import newsrack.database.sql.SQL_NewsIndex;
import newsrack.database.sql.SQL_ValType;
import newsrack.database.sql.SQL_StmtExecutor;
import newsrack.user.User;
import newsrack.filter.Issue;
import newsrack.filter.Category;
import newsrack.archiver.HTMLFilter;

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

   public static void changeNewsIndexDate(Long niKey, Date newDate)
   {
		((SQL_NewsIndex)_db.getNewsIndex(niKey)).changeDate(newDate);
   }

	public static void addNewsItemsToCat(Long catKey, String newsKeysFile)
	{
		try {
			Category       cat = _db.getCategory(catKey);
			BufferedReader br  = new BufferedReader(new java.io.FileReader(newsKeysFile));
			String         line;

			do {
				line = br.readLine();
				if (line != null) {
               NewsItem ni = _db.getNewsItem(Long.parseLong(line));
               //System.out.println("Will add " + ni.getTitle());
					_db.addNewsItem(ni, cat, 2);
            }
			} while (line != null);

			br.close();
		}
		catch (Exception e) {
			System.out.println("Exception: " + e);
		}
	}

	public static void updateCountsForAllIssues()
	{
      List<Issue> issues = User.getAllValidatedIssues();
		for (Issue i: issues) {
			i.storeNewsToArchive();
		}
	}

   public static void refetchNewsForNewsIndex(NewsIndex ni)
   {
      Collection<NewsItem> news = _db.getArchivedNews(ni);
      List<NewsItem> downloadedNews = new ArrayList<NewsItem>();
      for (NewsItem n: news) {
         File origOrig = ((SQL_NewsItem)n).getOrigFilePath();
         File origFilt = ((SQL_NewsItem)n).getFilteredFilePath();
         if (!origFilt.exists() || (origFilt.length() < 1500L)) {
            System.out.println("Will have to download " + origFilt + " again!");
            origOrig.delete();
            origFilt.delete();
            try {
               n.download(_db);
               downloadedNews.add(n);
            }
            catch (Exception e) {
               System.err.println("Error downloading news item: " + e);
            }
         }
         else if (origFilt.exists()) {
            System.out.println("No need to download " + origFilt + " again .. it has size " + origFilt.length());
         }
      }

         /* Now fetch all topics that monitor this feed! */
      List<Long> tkeys = (List<Long>)SQL_StmtExecutor.query("SELECT DISTINCT(t_key) FROM topic_sources WHERE feed_key = ?",
                                                            new SQL_ValType[] {SQL_ValType.LONG},
                                                            new Object[]{((SQL_NewsIndex)ni).getFeedKey()},
                                                            SQL_StmtExecutor._longProcessor,
                                                            false);
      for (Long tkey: tkeys) {
         Issue i = _db.getIssue(tkey);
         if (!i.isFrozen()) {
            System.out.println("Reclassifying for " + i.getName() + " for user " + i.getUser().getUid());
            i.scanAndClassifyNewsItems(null, downloadedNews);
         }
      }
   }

   public static void refetchNewsForNewsIndex(Long niKey)
   {
      refetchNewsForNewsIndex(_db.getNewsIndex(niKey));
   }

   public static void refetchFeedInDateRange(Long feedKey, Date startDate, Date endDate)
   {
      java.util.Iterator<? extends NewsIndex> nis = _db.getIndexesOfAllArchivedNews(feedKey, startDate, endDate);
      while (nis.hasNext()) {
         NewsIndex ni = nis.next();
         System.out.println("Will fetch news for index: " + ni.getKey() + "; date is " + ni.getCreationTime());
         refetchNewsForNewsIndex(ni);
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
      else if (action.equals("add-news-to-cat")) {
	      addNewsItemsToCat(Long.parseLong(args[2]), args[3]);
      }
      else if (action.equals("refetch-news")) {
         refetchNewsForNewsIndex(Long.parseLong(args[2]));
      }
      else if (action.equals("refetch-feed-in-date-range")) {
         Date sd = newsrack.web.BrowseAction.DATE_PARSER.get().parse(args[2]);
         Date ed = newsrack.web.BrowseAction.DATE_PARSER.get().parse(args[3]);
         for (int i = 4; i < args.length; i++) {
            Long fk = Long.parseLong(args[i]);
            refetchFeedInDateRange(fk,sd,ed);
         }
      }
      else {
         System.out.println("Unknown action: " + action);
      }

      System.out.println("\n -- DONE --");
      System.out.flush();
	}
}
