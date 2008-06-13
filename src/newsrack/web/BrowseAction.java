package newsrack.web;

import newsrack.GlobalConstants;
import newsrack.filter.Category;
import newsrack.filter.Issue;
import newsrack.archiver.Source;
import newsrack.user.User;
import newsrack.archiver.DownloadNewsTask;
import newsrack.database.NewsItem;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Collection;
import java.util.LinkedList;
import java.util.ArrayList;
import java.io.IOException;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * class <code>BrowseAction</code> implements the functionality
 * browsing through news archives of a particular user as well
 * as other public archives
 */
public class BrowseAction extends BaseAction
{
   private static final Log _log = LogFactory.getLog(UserAction.class); /* Logger for this action class */
	private static final SimpleDateFormat sdf = new SimpleDateFormat("MMM dd yyyy kk:mm z");

		// FIXME:  Pick some other view scheme than this!
	private static Date        _lastUpdateTime;
   private static List<Issue> _updatesMostRecent;
   private static List<Issue> _updatesLast24Hrs;
   private static List<Issue> _updatesMoreThan24Hrs;

		// Caching!
   public static void setIssueUpdateLists()
   {
      List<Issue> l1 = new ArrayList<Issue>();
      List<Issue> l2 = new ArrayList<Issue>();
      List<Issue> l3 = new ArrayList<Issue>();

      List<Issue> issues = User.getAllValidatedIssues();
		for (Issue i: issues) {
         int n = i.getNumItemsSinceLastDownload();
         if (n > 0)
            l1.add(i);
         else if ((n == 0) && i.updatedWithinLastNHours(24))
            l2.add(i);
         else
            l3.add(i);
      }

      _updatesMostRecent    = l1;
      _updatesLast24Hrs     = l2;
      _updatesMoreThan24Hrs = l3;
		_lastUpdateTime       = new Date();
   }

	private User   _user;
	private String _lastDownloadTime;

		/* These 4 params are for the common browse case:
		 * top-level browse; user browse; issue browse */
	private User     _issueOwner;
	private Issue    _issue;
	private Category _cat;
	private List<Category> _catAncestors;

		/* These 4 params are for the uncommon browse case:
		 * for browsing news by source */
	private Source   _src;
	private String   _d;
	private String   _m;
	private String   _y;

		/* News list to be displayed */
	private Collection<NewsItem> _news;

/**
	private int _start;
	private int _count;   
**/

	public User getUser() { return _user; }
	public String getLastDownloadTime() { return _lastDownloadTime; }
	public Collection<NewsItem> getNews() { return _news; }

	public User getOwner() { return _issueOwner; } 
	public Issue getIssue() { return _issue; } 
	public Category getCat() { return _cat; } 
	public List<Category> getCatAncestors() { return _catAncestors; }

	public String getDate() { return _d; }
	public String getMonth() { return _m; }
	public String getYear() { return _y; }
	public Source getSource() { return _src; }

	public List<Issue> getMostRecentUpdates() { return _updatesMostRecent; }
	public List<Issue> getLast24HourUpdates() { return _updatesLast24Hrs; }
	public List<Issue> getOldestUpdates()     { return _updatesMoreThan24Hrs; }

   public String execute()
	{
		_user = getSessionUser();

		/* Do some error checking, fetch the issue, and the referenced category
		 * and pass control to the news display routine */
		Date ldt = DownloadNewsTask.getLastDownloadTime();
		synchronized(sdf) {
			_lastDownloadTime = sdf.format(ldt);
		}

		String uid = getParam("owner");
		if (uid == null) {
			String srcId = getParam("srcId");
			if (srcId == null) {
				// No uid, no source params -- send them to the top-level browse page!
				if ((_updatesMostRecent == null) || _lastUpdateTime.before(ldt))
					setIssueUpdateLists();

				return "browse.main";
			}

				// If there is no valid session, send them to the generic browse page!
			if (_user == null) {
				_log.error("Expired session!");
				return "browse.main";
			}

				// Fetch source
			_src = _user.getSourceById(srcId);
			if (_src == null) {
				_log.error("Unknown source: " + srcId);
				return "browse.source";
			}

			_d = getParam("d");
			_m = getParam("m");
			_y = getParam("y");
			if ((_d == null) || (_m == null) && (_y == null)) {
				_log.error("Bad date params: d- " + _d + ", m- " + _m + ", y- " + _y);
				return "browse.source";
			}

				// Fetch news for the source for the requested date
			_news = _src.getArchivedNews(_y, _m, _d);
			if (_news == null)
				_news = new ArrayList<NewsItem>();

/**
			// FIXME: Is this required?? -- perhaps this will already be available!
			_start = getParam("start"); // Starting index from where news should be displayed
			_count = getParam("count"); // Number of news items that should be displayed on this page
**/
			return "browse.source";
		}
		else {
			boolean selfBrowse = ((_user != null) && _user.getUid().equals(uid));
			_issueOwner = selfBrowse ? _user : User.getUser(uid);
			if (_issueOwner == null) {
					// Bad uid given!  Send the user to the top-level browse page
				_log.error("No user with uid: " + uid);
				return "browse.main";
			}

			String issueName = getParam("issue");
			if (issueName == null) {
					// No issue parameter for the user.  Send them to a issue listing page for that user!
				return "browse.user";
			}

			_issue = _issueOwner.getIssue(issueName);
			if (_issue == null) {
					// Bad issue-name parameter.  Send them to a issue listing page for that user!
				_log.error("No issue with name: " + issueName + " defined for user: " + uid);
				return "browse.user";
			}

			String catId = getParam("catID");
			if (catId == null) {
					// No cat specified -- browse the issue!
				return "browse.issue";
			}

			_cat = _issue.getCategory(Integer.parseInt(catId));
			if (_cat == null) {
					// Bad category!  Send them to a listing page for the issue! 
				_log.error("Category with id " + catId + " not defined in issue " + issueName + " for user: " + uid);
				return "browse.issue";
			}

				// Set up the ancestor list for the category
			Category c = _cat;
			LinkedList<Category> ancestors = new LinkedList<Category>();
			while (c != null) {
				c = c.getParent();
				if (c != null)
					ancestors.addFirst(c);
			}
			_catAncestors = ancestors;

	/**
				// FIXME: Is this required?? -- perhaps this will already be available!
			_start = getParam("start"); // Starting index from where news should be displayed
			_count = getParam("count"); // Number of news items that should be displayed on this page
	**/

				// Display news in the current category in the current issue
			return _cat.isLeafCategory() ? "browse.news" : "browse.cat";
		}
	}
}
