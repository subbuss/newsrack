package newsrack.web;

import java.util.Map;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import newsrack.GlobalConstants;
import newsrack.user.User;

public class LoginAction extends BaseAction
{
   private static final Log _log = LogFactory.getLog(LoginAction.class); /* Logger for this action class */

	public void validate()
	{
      String uid  = getParam("username");
		if (uid == null || uid.trim().equals(""))
			addFieldError("username", getText("error.username.required"));

      String pass = getParam("password");
		if (pass == null || pass.equals(""))
			addFieldError("password", getText("error.password.required"));
	}

	public String execute()
	{
      String uid  = getParam("username");
      String pass = getParam("password");
		try {
			User u = User.signInUser(uid, pass);
			_session.put(GlobalConstants.USER_KEY, u);
			if (u.isAdmin())
				return "admin.login";
			else
				return Action.SUCCESS;
		}
		catch (UnknownUserException e) {
			addFieldError("username", getText("error.invalid.uid", new String[]{uid}));
			return Action.INPUT;
		}
		catch (InvalidPasswordException e) {
			addFieldError("password", getText("error.invalid.password"));
			return Action.INPUT;
		}
		catch (Exception e) {
			addActionError(getText("internal.app.error"));
			_log.error("Exception signing in user!", e);
			return "internal.app.error";
		}
	}
}
