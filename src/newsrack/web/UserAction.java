package newsrack.web;

import com.opensymphony.xwork2.Action;
import newsrack.NewsRack;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * class <code>UserAction</code> supports various user-screen specific tasks
 */
public class UserAction extends BaseAction {
    private static final Log _log = LogFactory.getLog(UserAction.class); /* Logger for this action class */

    public void validateChangePassword() {
        String oldPass = getParam("oldPassword");
        if (oldPass == null || oldPass.equals(""))
            addFieldError("password", getText("error.password.required"));

        validatePasswordPair("newPassword", "newPasswordConfirm");
    }

    public String changePassword() {
        try {
            _user.changePassword(getParam("oldPassword"), getParam("newPassword"));
            return Action.SUCCESS;
        } catch (InvalidPasswordException e) {
            addActionError(getText("error.invalid.password"));
            return Action.ERROR;
        }
    }

    public String logout() {
        // The ClearSessionInterceptor clears the session, so, nothing else to do here!
        // FIXME: ClearSessionInterceptor is not working for some reason ... what am I doing wrong?
        _session.remove(NewsRack.USER_KEY);
        _session.remove(NewsRack.UID_KEY);
        return "home";
    }
}
