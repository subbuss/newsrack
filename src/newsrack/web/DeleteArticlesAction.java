package newsrack.web;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.List;
import java.util.ArrayList;
import java.util.LinkedList;
import java.io.IOException;

import newsrack.GlobalConstants;
import newsrack.user.User;
import newsrack.filter.Issue;
import newsrack.filter.Category;

/**
 * class <code>DeleteArticlesAction</code> implements the functionality
 * of deleting articles from a user's category
 */
public class DeleteArticlesAction extends BaseAction
{
   private static Log _log = LogFactory.getLog(DeleteArticlesAction.class);	/* Logger for this action class */

	private User     _user;
	private Issue    _issue;
	private Category _currCat;
	private List<Category> _catAncestors;
	private String _lastDownloadTime;

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

	public User getUser() { return _user; }
	public String getLastDownloadTime() { return _lastDownloadTime; }
	public User getOwner() { return _user; } 
	public Issue getIssue() { return _issue; } 
	public Category getCat() { return _currCat; } 
	public List<Category> getCatAncestors() { return _catAncestors; }

   public String execute()
	{
		_user = getSessionUser();

      int  catID   = -1;
      int  start   = -1;
      int  count   = -1;
      long gCatKey = (long)-1;
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
		   _user = getSessionUser();
      }

         // Now, send the user back to the same query page from where this action was initiated!
		java.util.Date ldt = newsrack.archiver.DownloadNewsTask.getLastDownloadTime();
		synchronized(GlobalConstants.DF) {
			_lastDownloadTime = GlobalConstants.DF.format(ldt);
		}

      if (issueName != null) {
         _issue = _user.getIssue(issueName);
         if (_issue != null) {
				if (catID > 0) {
					_currCat = _issue.getCategory(catID);
               if (_currCat != null) {
                     // Set up ancestor list
                  LinkedList<Category> ancestors = new LinkedList<Category>();
						Category cat = _currCat;
                  while (cat != null) {
                     cat = cat.getParent();
                     if (cat != null)
                        ancestors.addFirst(cat);
                  }
						_catAncestors = ancestors;
               }
            }
         }
      }

		return Action.SUCCESS;
	}
}
