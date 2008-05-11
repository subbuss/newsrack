package newsrack.web;

import newsrack.GlobalConstants;
import newsrack.user.User;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;

/**
 * class <code>DownloadNewsAction</code> implements the functionality
 * of downloading the latest news.
 */
public class DownloadNewsAction extends BaseAction
{
   private static final Log log = LogFactory.getLog(DownloadNewsAction.class); /* Logger for this action class */

	private User _user;

	public User getUser() { return _user; } 

   public String execute()
   {
		_user = getSessionUser();

		try {
			_user.downloadNews();
			return Action.SUCCESS;
		}
		catch (Exception e) {
			log.error("Error downloading news!", e);
			return Action.ERROR;
		}
	}
}
