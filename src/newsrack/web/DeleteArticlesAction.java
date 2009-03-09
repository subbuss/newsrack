package newsrack.web;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

import newsrack.NewsRack;
import newsrack.archiver.Source;
import newsrack.database.NewsItem;
import newsrack.filter.Category;
import newsrack.filter.Issue;
import newsrack.user.User;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.opensymphony.xwork2.Action;

/**
 * class <code>DeleteArticlesAction</code> implements the functionality
 * of deleting articles from a user's category
 */
public class DeleteArticlesAction extends BaseAction
{
   private static Log _log = LogFactory.getLog(DeleteArticlesAction.class);	/* Logger for this action class */

	private Issue    _issue;
	private Category _cat;
	private List<Category> _catAncestors;
	private String _lastDownloadTime;

	private int _numArts;
	private int _start;
	private int _count;
	private Collection<NewsItem> _news;

   private String getParamValue(String paramName)
   {
      String paramValue = getParam(paramName);
      if (paramValue.length() == 0) {
         _log.error("NO PARAM VALUE for " + paramName);
         return null;
      }
      else {
         return paramValue;
      }
   }

	public String getLastDownloadTime() { return _lastDownloadTime; }
	public int    getNumArts()          { return _numArts; }
	public int    getStart()            { return _start; }
	public int    getCount()            { return _count; }
	public Collection<NewsItem> getNews() { return _news; }
	public User getOwner() { return _user; } 
	public Issue getIssue() { return _issue; } 
	public Category getCat() { return _cat; } 
	public List<Category> getCatAncestors() { return _catAncestors; }

   public String execute()
	{
      int  catID   = -1;
      int  start   = -1;
      int  count   = -1;
      long gCatKey = -1;
      String issueName = null;
      List<Long> keys = new ArrayList<Long>();
		try {
            /* I have to process the parameters this way because
				 * I don't know all the parameters that are being passed in */
			for (Object pn: _params.keySet()) {
				String paramName = (String)pn;
            if (paramName.startsWith("key")) {
               String pv = getParamValue(paramName);
               if (pv != null)
                  keys.add(Long.valueOf(pv));
               else
                  continue;
            }
            else if (paramName.equals("globalCatKey")) {
               String pv = getParamValue(paramName);
               if (pv != null)
                  gCatKey = Long.parseLong(pv);
            }
            else if (paramName.equals("issue")) {
               issueName = getParamValue(paramName);
            }
            else if (paramName.equals("catID")) {
               String pv = getParamValue(paramName);
               if (pv != null)
                  catID = Integer.parseInt(pv);
            }
            else if (paramName.equals("start")) {
               String pv = getParamValue(paramName);
               if (pv != null)
                  start = Integer.parseInt(pv);
            }
            else if (paramName.equals("count")) {
               String pv = getParamValue(paramName);
               if (pv != null)
                  count = Integer.parseInt(pv);
            }
         }
			addActionMessage(getText("msg.articles.deleted"));
		}
		catch (Exception e) {
			_log.error("Exception", e);
			addActionError(getText("error.articles.delete"));
		}

         // Now, delete all the news items that have been marked
      if (gCatKey != -1) {
			Category.deleteNewsItems(gCatKey, keys);
            // Refresh the user object!
            // Without this, the fetched issue in the code below will be stale
		   refreshSessionUserObject();
      }

         // Now, send the user back to the same query page from where this action was initiated!
		java.util.Date ldt = newsrack.archiver.DownloadNewsTask.getLastDownloadTime();
		synchronized(NewsRack.DF) {
			_lastDownloadTime = NewsRack.DF.format(ldt);
		}

      if (issueName != null) {
         _issue = _user.getIssue(issueName);
         if (_issue != null) {
				if (catID > 0) {
					_cat = _issue.getCategory(catID);
               if (_cat != null) {
                     // Set up ancestor list
                  LinkedList<Category> ancestors = new LinkedList<Category>();
						Category cat = _cat;
                  while (cat != null) {
                     cat = cat.getParent();
                     if (cat != null)
                        ancestors.addFirst(cat);
                  }
						_catAncestors = ancestors;
                  _numArts = _cat.getNumArticles(); 
                     // Start
                  String startVal = getParam("start");
                  if (startVal == null) {
                     _start = 0;
                  }
                  else {
                     _start = Integer.parseInt(startVal)-1;
                     if (_start < 0)
                        _start = 0;
                     else if (_start > _numArts)
                        _start = _numArts;
                  }

                     // Count
                  String countVal = getParam("count");
                  if (countVal == null) {
                     _count = BrowseAction.DEF_NUM_ARTS_PER_PAGE;
                  }
                  else {
                     _count = Integer.parseInt(countVal);
                     if (_count < BrowseAction.MIN_NUM_ARTS_PER_PAGE)
                        _count = BrowseAction.MIN_NUM_ARTS_PER_PAGE;
                     else if (_count > BrowseAction.MAX_NUM_ARTS_PER_PAGE)
                        _count = BrowseAction.MAX_NUM_ARTS_PER_PAGE;
                  }

                     // Filter by source
                  String srcTag = getParam("source_tag");
                  Source src    = null;
                  if ((srcTag != null) && (srcTag != ""))
                     src = _issue.getSourceByTag(srcTag);

                  Date startDate = null;
                  String sdStr = getParam("start_date");
                  if (sdStr != null) {
                     try {
                        startDate = BrowseAction.DATE_PARSER.get().parse(sdStr);
                     }
                     catch (Exception e) {
                        addActionError(getText("bad.date", sdStr));
                        _log.info("Error parsing date: " + sdStr + e);
                     }
                  }

                     // Filter by start & end dates
                  Date endDate = null;
                  String edStr = getParam("end_date");
                  if (edStr != null) {
                     try {
                        endDate = BrowseAction.DATE_PARSER.get().parse(edStr);
                     }
                     catch (Exception e) {
                        addActionError(getText("bad.date", edStr));
                        _log.info("Error parsing date: " + edStr + e);
                     }
                  }

                  //_log.info("Browse: owner uid - " + uid + "; issue name - " + issueName + "; catID - " + catId + "; start - " + _start + "; count - " + _count + "; start - " + startDate + "; end - " + endDate + "; srcTag - " + srcTag + "; src - " + (src != null ? src.getKey() : null));

                     // Fetch news!
                  _news  = _cat.getNews(startDate, endDate, src, _start, _count);
               }
            }
         }
      }

		return Action.SUCCESS;
	}
}
