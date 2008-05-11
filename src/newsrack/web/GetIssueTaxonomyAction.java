package newsrack.web;

import newsrack.filter.Issue;
import newsrack.user.User;

import java.io.IOException;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts2.interceptor.ServletResponseAware;
import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * class <code>GetIssueTaxonomyAction</code> implements the functionality
 * of displaying the taxonmy for an issue in XML
 */
public class GetIssueTaxonomyAction extends BaseAction implements ServletResponseAware
{
   private static Log _log = LogFactory.getLog(GetIssueTaxonomyAction.class);

		// ServletResponseAware
   private HttpServletResponse _response;
   public void setServletResponse(HttpServletResponse r) { _response = r; }

   public String execute()
	{
		try {
			String user = getParam("user");
			if (user == null) {
				_log.error("User not specified");
				return Action.ERROR;
			}
			User u = User.getUser(user);
			if (u == null) {
				_log.error("GetIssueTaxonomy: Unknown user id: " + user);
				return Action.ERROR;
			}
			String issue = getParam("issue");
			if (issue == null) {
				_log.error("Issue not specified");
				return Action.ERROR;
			}
			Issue i = u.getIssue(issue);
			if (i == null) {
				_log.error("GetIssueTaxonomy: Unknown issue: " + issue);
				return Action.ERROR;
			}

				// All lights go!
			_response.setContentType("text/xml");
			_response.getOutputStream().println(i.getTaxonomy());

				// No need to return any mapping here
			return null;
		}
		catch (Exception e) {
			_log.error("Error displaying taxonomy!", e);
			return Action.ERROR;
		}
	}
}
