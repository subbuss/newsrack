package newsrack.web;

import java.io.IOException;
import java.util.List;

import newsrack.filter.PublicFile;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import newsrack.GlobalConstants;
import newsrack.user.User;

/**
 * class <code>PublicFilesAction</code> implements the functionality
 * of displaying the publicly available files of a particular type
 * (categories, profiles, concepts, news sources)
 */

public class PublicFilesAction extends BaseAction
{
   private static Log _log = LogFactory.getLog(PublicFilesAction.class);	/* Logger for this action class */

	private User _user;
	private List<PublicFile> _publicFiles;

	public User getUser() { return _user; }
	public List<PublicFile> getPublicFiles() { return _publicFiles; }

   public String execute()
	{
		_user = getSessionUser();
		_publicFiles = User.getPublicFiles();
		return Action.SUCCESS;
	}
}
