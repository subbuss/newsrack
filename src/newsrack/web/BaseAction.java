package newsrack.web;

import java.util.Map;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;
import org.apache.struts2.interceptor.SessionAware;
import org.apache.struts2.interceptor.ParameterAware;

import newsrack.GlobalConstants;
import newsrack.user.User;

/**
 * class <code>BaseAction</code> is the base class for all
 * actions that require the user to be signed in!
 */
public abstract class BaseAction extends ActionSupport implements SessionAware, ParameterAware
{
		// Session Aware
	Map _session;
	public void setSession(Map s)    { _session = s; }

		// Parameter Aware
	Map _params;
	public void setParameters(Map p) { _params = p; }

   User _user;
   public User getUser() { return _user; }

	User getSessionUser()
	{
			// NOTE: To get around caching & invalidation problems, we need to go
			// back to the db/cache for every user request -- so that we always
			// get latest info for a user.
      _user = User.getUser((String)_session.get(GlobalConstants.UID_KEY));
		_session.put(GlobalConstants.USER_KEY, _user);
		return _user;
	}

	String getParam(String key)
	{
		String[] vals = (String[])_params.get(key);
		return (vals == null) ? null : vals[0];
	}

	String[] getParamValues(String key)
	{
		return (String[])_params.get(key);
	}

	void validatePasswordPair(String fieldName1, String fieldName2)
	{
      String pass1 = getParam(fieldName1);
      String pass2 = getParam(fieldName2);
		if (pass1 == null || pass1.equals(""))
			addFieldError(fieldName1, getText("error.password.required"));
		if (pass2 == null || pass2.equals(""))
			addFieldError(fieldName2, getText("error.password.required"));
		if (!pass1.equals(pass2))
			addFieldError(fieldName2, getText("error.password.mismatch"));
	}
}
