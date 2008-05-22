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

	private String _username;

		/** Set this param so that it is available in the form when there are errors */ 
	public void setUsername(String u) { _username = u; }
	public String getUsername() { return _username; }

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
	}
}
