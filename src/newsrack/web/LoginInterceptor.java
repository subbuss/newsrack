package newsrack.web;

import java.util.Map;
import java.util.Set;

import newsrack.NewsRack;
import newsrack.user.User;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.interceptor.AbstractInterceptor;

public class LoginInterceptor extends AbstractInterceptor
{
	public static final String LOGIN_TARGET_KEY = "login.target";

   private static final Log _log = LogFactory.getLog(LoginInterceptor.class); /* Logger for this class */

	public LoginInterceptor() { super(); }

	@Override
	public String intercept(ActionInvocation invocation) throws Exception
	{
		Map session       = invocation.getInvocationContext().getSession();
		Map requestParams = invocation.getInvocationContext().getParameters();
      Object uid = session.get(NewsRack.UID_KEY);
      if (uid == null) {
    		int    count = 0;
    		String requestString = "";
    		Set<String> keys = requestParams.keySet();
			for (String k: keys) {
				String[] val = (String[])requestParams.get(k);
				requestString += (count == 0) ? "?" : "&"; 		// if it's the first parameter add a '?' else add a '&'
				requestString += k + "=" + val[0].toString(); // append the key = val param string
				count++;
			}

			String namespace  = invocation.getProxy().getNamespace();
    		String actionName = invocation.getProxy().getActionName();
			String targetUrl  = namespace + "/" + actionName + ".action" + requestString;

				// Record the url the user should be redirected to after logging in
			session.put(LOGIN_TARGET_KEY, targetUrl);

			return "login";
      }
		else {
				// NOTE: To get around caching & invalidation problems, we need to go
				// back to the db/cache to get the latest user object for each request!
			User u = User.getUser((String)uid);
			if (_log.isDebugEnabled()) _log.debug("setting user to: " + ((u == null) ? null: u.getUid()));

			// FIXME: Get rid of the session user object, and maybe use the value stack as below 
			//
			// invocation.getStack().set(NewsRack.USER_KEY, u); // Push the user object on the value stack
			//
			// But, the problem is those actions where the user object changes as a result of the action
			// ... login, admin, reset-password ... how do I get rid of the session put there??

			invocation.getInvocationContext().getSession().put(NewsRack.USER_KEY, u);
			if (invocation.getAction() instanceof BaseAction)
				 ((BaseAction)invocation.getAction()).setUser(u);

         return invocation.invoke();
      }
   }
}
