package newsrack.web;

import java.util.Map;
import java.util.Set;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.interceptor.AbstractInterceptor;

import newsrack.GlobalConstants;

public class LoginInterceptor extends AbstractInterceptor
{
	public static final String LOGIN_TARGET_KEY = "login.target";

   private static final Log log = LogFactory.getLog(LoginInterceptor.class); /* Logger for this class */

	public LoginInterceptor() { super(); }

	@Override
	public String intercept(ActionInvocation invocation) throws Exception
	{
		Map session       = invocation.getInvocationContext().getSession();
		Map requestParams = invocation.getInvocationContext().getParameters();
      Object user = session.get(GlobalConstants.USER_KEY);
      if (user == null) {
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
         return invocation.invoke();
      }
   }
}
