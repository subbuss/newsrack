package newsrack.web;

import newsrack.user.User;
import newsrack.util.ParseUtils;
import newsrack.filter.Issue;

import java.util.Iterator;
import java.io.IOException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.opensymphony.xwork2.Action;

/**
 * class <code>EditProfileAction</code> implements the functionality of editing the user profile.
 */
public class EditProfileAction extends BaseAction
{
   private static final Log _log = LogFactory.getLog(EditProfileAction.class); /* Logger for this action class */

	public String getUserHome() { return _user.getFileUploadArea(); }

   public String execute()
	{
		String action = getParam("action");
		if (action != null) {
			if (action.equals("deleteFile")) {
				String name = getParam("file");
				try {
					_user.deleteFile(name);
				}
				catch (Exception e) {
					addActionError(getText("error.file.delete", new String[]{name})); 
					_log.error("Edit error: " + e);
				}
            finally {
               BrowseAction.setIssueUpdateLists();
            }
			}
			else if (action.equals("validateProfile")) {
					// Attempt to validate all defined issues 
				try {
						// Validate issues and generate scanners
					_user.validateIssues(true);
				}
				catch (Exception e) {
					_log.error("Exception: ", e);

						// Display all parsing errors
					Iterator parseErrs = ParseUtils.getParseErrors(_user);
					if (parseErrs != null) {
						StringBuffer buf = new StringBuffer();
						while (parseErrs.hasNext()) {
							buf.append(parseErrs.next()).append("<br>");
						}
						addActionError(buf.toString());
					}
				}
            finally {
               BrowseAction.setIssueUpdateLists();
            }
			}
			else if (action.equals("disableActiveProfile")) {
            try { _user.invalidateAllIssues(); }
            finally { BrowseAction.setIssueUpdateLists(); }
			}
			else if (action.equals("freeze")) {
				String iname = getParam("issue");
				Issue  i     = _user.getIssue(iname);
				if (i == null) {
					_log.error("Edit error: Unknown issue name " + iname);
				}
				else {
					i.freeze();
				}
			}
			else if (action.equals("unfreeze")) {
				String iname = getParam("issue");
				Issue  i     = _user.getIssue(iname);
				if (i == null) {
					_log.error("Edit error: Unknown issue name " + iname);
				}
				else {
					i.unfreeze();
				}
			}
		}

		return Action.SUCCESS;
	}
}
