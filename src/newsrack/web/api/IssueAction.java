package newsrack.web.api;

import com.opensymphony.xwork2.Action;
import newsrack.filter.Issue;
import newsrack.user.User;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * class <code>IssueAction</code> implements the functionality of api access to issue objects
 */
public class IssueAction extends BaseApiAction {
    private static Log _log = LogFactory.getLog(IssueAction.class);

    private Issue _issue;

    public Issue getIssue() {
        return _issue;
    }

    private boolean setupParams() {
        // User - mandatory (either owner= or user= accept both for now)
        String uid = getApiParamValue("owner", false);
        if (uid == null)
            uid = getApiParamValue("user", false);

        User u = (uid == null) ? null : User.getUser(uid);
        if (!validateParam(u, "owner_uid", uid))
            return false;

        // Issue - mandatory
        String issueName = getApiParamValue("issue", false);
        _issue = (issueName == null) ? null : u.getIssue(issueName);
        if (!validateParam(_issue, "issue_name", issueName))
            return false;

        return true;
    }

    private String setupResults() {
        try {
            if (!setupParams())
                return Action.ERROR;

            // Done -- XML or JSON!
            String outType = getParam("output");
            return (outType == null) ? "xml" : outType;
        } catch (Exception e) {
            _log.error("Error displaying taxonomy!", e);
            return Action.ERROR;
        }
    }

    public String getTaxonomy() {
        return setupResults();
    }

    public String getMonitoredSources() {
        return setupResults();
    }
}
