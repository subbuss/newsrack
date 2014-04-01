package newsrack.web;

import com.opensymphony.xwork2.Action;
import newsrack.NewsRack;
import newsrack.user.User;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class LoginAction extends BaseAction {
    private static final Log _log = LogFactory.getLog(LoginAction.class); /* Logger for this action class */

    private String _username;

    public String getUsername() {
        return _username;
    }

    /**
     * Set this param so that it is available in the form when there are errors
     */
    public void setUsername(String u) {
        _username = u;
    }

    public void validate() {
        String uid = getParam("username");
        if (uid == null || uid.trim().equals(""))
            addFieldError("username", getText("error.username.required"));

        String pass = getParam("password");
        if (pass == null || pass.equals(""))
            addFieldError("password", getText("error.password.required"));
    }

    public String execute() {
        String uid = getParam("username");
        String pass = getParam("password");

        try {
            // FIXME: Get rid of the user object from the session!
            User u = User.signInUser(uid, pass);
            _session.put(NewsRack.UID_KEY, u.getUid());
            _session.put(NewsRack.USER_KEY, u);
            newsrack.database.DB_Interface dbi = NewsRack.getDBInterface();
            dbi.updateUserAttribute(u, dbi.LAST_LOGIN, new java.util.Date());
            _log.info("Signed in user " + uid);
            if (u.isAdmin())
                return "admin.login";
            else
                return Action.SUCCESS;
        } catch (UnknownUserException e) {
            addFieldError("username", getText("error.invalid.uid", new String[]{uid}));
            return Action.INPUT;
        } catch (InvalidPasswordException e) {
            addFieldError("password", getText("error.invalid.password"));
            return Action.INPUT;
        }
    }
}
