package newsrack.web;

import java.util.Map;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import newsrack.GlobalConstants;
import newsrack.user.User;

/**
 * class <code>AdminAction</code> presents an admin screen!
 */
public class AdminAction extends BaseAction
{
   private static final Log log = LogFactory.getLog(AdminAction.class); /* Logger for this action class */

	private User _user;

	private User getUser() { return _user; }

   private User getAdmin()
   {
	   User u = getSessionUser();
		if (u != null && !u.isAdmin()) { // Check if this is indeed the admin
			addActionError(getText("error.not.admin"));
			log.error("User " + u.getUid() + " not an admin!");
			return null;
		}

		return u;
	}

	public String loginAsAnotherUser()
	{
		User u = getAdmin();
		if (u == null)
			return Action.ERROR;

		String username = getParam("username");
		if (username == null) {
			addActionError(getText("error.username.required"));
			log.error("User name not provided!");
			return Action.INPUT;
		}

		try {
				// Save our logged-in user in the session,
				// because we use it again later.
			log.info("ADMIN: got username - " + username);
			u = u.signInAsUser(username);
			log.info("ADMIN: Signed in as user " + u.getUid());

				// Record the new user info in the action class
			_user = u;
			_session.put(GlobalConstants.USER_KEY, _user);
			return Action.SUCCESS;
		}
		catch (final Exception e) {
			addActionError(getText("error.invalid.uid", new String[]{username}));
			log.error("Bad username?", e);
			return Action.INPUT;
		}
	}

	public String refreshCachingRules()
	{
		User u = getAdmin();
		if (u == null)
			return Action.ERROR;

		newsrack.archiver.Feed.refreshCachedTextDisplayRules();
		return Action.SUCCESS;
	}

	public String refreshGlobalProperties()
	{
		User u = getAdmin();
		if (u == null)
			return Action.ERROR;

      GlobalConstants.loadGlobalProperties();
		return Action.SUCCESS;
	}
}
