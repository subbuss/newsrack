package newsrack.web.api;

import newsrack.filter.Issue;
import newsrack.user.User;
import newsrack.web.BaseAction;

import java.io.IOException;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * class <code>GetIssueTaxonomyAction</code> implements the functionality
 * of displaying the taxonomy for an issue in XML
 */
public class GetIssueTaxonomyAction extends BaseApiAction
{
   private static Log _log = LogFactory.getLog(GetIssueTaxonomyAction.class);

	private Issue _issue;
	public Issue getIssue() { return _issue; }

   public String execute()
	{
		try {
				// User - mandatory
			String uid = getApiParamValue("user", false);
			User   u   = (uid == null) ? null : User.getUser(uid);
			if (!validateParam(u, "user_name", uid))
				return Action.ERROR;

				// Issue - mandatory
			String issueName = getApiParamValue("issue", false);
			_issue = (issueName == null) ? null : u.getIssue(issueName);
			if (!validateParam(_issue, "issue_name", issueName))
				return Action.ERROR;

				// Done -- XML or JSON!
			String outType = getParam("outputType");
			return (outType == null) ? "xml" : outType;
		}
		catch (Exception e) {
			_log.error("Error displaying taxonomy!", e);
			return Action.ERROR;
		}
	}
}
