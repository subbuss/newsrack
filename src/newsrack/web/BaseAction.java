package newsrack.web;

import java.util.Map;

import newsrack.NewsRack;
import newsrack.user.User;

import org.apache.struts2.interceptor.ParameterAware;
import org.apache.struts2.interceptor.SessionAware;

import com.opensymphony.xwork2.ActionSupport;

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
	public void setUser(User u) { _user = u; }	// Set by the LoginInterceptor
   // public User getUser()       { return _user; }

	void refreshSessionUserObject()
	{
			// NOTE: To get around caching & invalidation problems, we need to go
			// back to the db/cache for every user request -- so that we always
			// get latest info for a user.
		String uid = (String)_session.get(NewsRack.UID_KEY);
		if (uid != null) {
			User u = User.getUser(uid); 
			_session.put(NewsRack.USER_KEY, u);
			setUser(u);
		}
	}

	protected String getParam(String key)
	{
		String[] vals = (String[])_params.get(key);
		return (vals == null) ? null : vals[0];
	}

	protected String[] getParamValues(String key)
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
