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

	User getSessionUser()
	{
		return (User)_session.get(GlobalConstants.USER_KEY);
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
}
