package newsrack.database.sql.scripts;

import java.util.Collection;
import java.util.List;

import newsrack.NewsRack;
import newsrack.database.DB_Interface;
import newsrack.database.NewsIndex;
import newsrack.database.NewsItem;
import newsrack.user.User;
import newsrack.filter.Issue;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class FixupTools
{
   private static Log _log = LogFactory.getLog((new FixupTools()).getClass());

	private static DB_Interface _db = NewsRack.getDBInterface();

	public static void findNewsItemsWithMissingFiles(long newsIndexKey)
	{
		NewsIndex            ni   = _db.getNewsIndex(newsIndexKey);
		Collection<NewsItem> news = _db.getArchivedNews(ni);
		for (NewsItem n: news) {
			try {
				n.getReader().close();
			}
			catch (java.io.FileNotFoundException e) {
				System.out.println("No file for " + n.getKey());
			}
			catch (Exception e) {
				System.out.println("Exception: " + e + " for news item: " + n.getKey());
			}
		}
	}

	public static void updateCountsForAllIssues()
	{
      List<Issue> issues = User.getAllValidatedIssues();
		for (Issue i: issues) {
			i.storeNewsToArchive();
		}
	}

	public static void main(String[] args)
	{
		if (args.length < 1) {
			System.out.println("Usage: java newsrack.database.sql.scripts.FixupTools <properties-file> [<other-optional-args>]");
			System.exit(0);
		}

   	String appPropertiesFile = args[0];
		System.out.println("Properties file: " + appPropertiesFile);

		NewsRack.startup(null, appPropertiesFile);
	}
}
