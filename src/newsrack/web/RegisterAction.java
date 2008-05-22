package newsrack.web;

import java.util.Map;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import newsrack.GlobalConstants;
import newsrack.user.User;

public class RegisterAction extends BaseAction
{
	private static final int UID_MAX_LENGTH = 15;

   private static final Log _log = LogFactory.getLog(RegisterAction.class); /* Logger for this action class */

		/** Set these three params so that they are available in the form when there are errors */ 
	private String _name;
	private String _username;
	private String _emailid;

	public void setName(String n) {  _name = n; }
	public String getName() { return _name; }

	public void setUsername(String n) {  _username = n; }
	public String getUsername() { return _username; }

	public void setEmailid(String e) {  _emailid = e; }
	public String getEmailid() { return _emailid; }

	private void validateUserId(String uid)
	{
		if (!User.userIdAvailable(uid)) {
			addFieldError("username", getText("error.uid.unavailable", new String[]{uid}));
			return;
		}

		int n = uid.length();
		if (n > UID_MAX_LENGTH) {
			addFieldError("username", getText("error.string.toolong", new String[]{uid}));
			return;
		}

		char[] cs = uid.toCharArray();
		for (int i = 0; i < n; i++) {
			char c = cs[i];
				// White space cannot be part of a valid uid!
			if (Character.isWhitespace(c))
				addFieldError("username", "You chose '" + uid + "' as your username.  Character '" + c + "' at position " + i + " cannot be used in a user name!");
				// No special characters allowed!
			if (   ((i == 0) && !Character.isUnicodeIdentifierStart(c))
				 || ((i > 0)  && !Character.isUnicodeIdentifierPart(c) && (c != '_'))
				)
			{
				addFieldError("username", "You chose '" + uid + " as your username. Character '" + c + "' at position " + i + " cannot be used in a user name!  Start with a letter and use letters, numbers, or _ elsewhere!");
			}
		}
	}

	public void validate()
	{
      String uid = getParam("username");
		if (uid == null || uid.trim().equals(""))
			addFieldError("username", getText("error.username.required"));
		else
			validateUserId(_username);

		validatePasswordPair("password", "passwordConfirm");

			// This is one crude way to handle robot registrations
		String hsv = getParam("humanSumValue");
		String hsr = getParam("humanSumResponse");
		try {
			if ((hsr == null) || !Integer.valueOf(hsv).equals(Integer.valueOf(hsr)))
				addFieldError("humansum", "If you are a human trying to register, please enter " + hsv + " in the box asking for the sum.");
		}
		catch (NumberFormatException e) {
			addFieldError("humansum", "If you are a human trying to register, please enter " + hsv + " in the box asking for the sum.");
		}

		String emailid = getParam("emailid");
		if (emailid == null || emailid.trim().equals(""))
			addFieldError("password", getText("error.emailid.required"));
	}

	public String execute()
	{
		User u = User.registerUser(getParam("username"), getParam("password"), getParam("name"), getParam("emailid"));
		assert(u != null);
		return Action.SUCCESS;
	}
}
