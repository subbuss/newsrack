package newsrack.web;

import com.opensymphony.xwork2.Action;
import newsrack.filter.PublicFile;
import newsrack.user.User;

import java.util.List;

// import org.apache.commons.logging.Log;
// import org.apache.commons.logging.LogFactory;

/**
 * class <code>PublicFilesAction</code> implements the functionality
 * of displaying the publicly available files of a particular type
 * (categories, profiles, concepts, news sources)
 */

public class PublicFilesAction extends BaseAction {
    // private static Log _log = LogFactory.getLog(PublicFilesAction.class);	// Logger for this action class

    private List<PublicFile> _publicFiles;

    public List<PublicFile> getPublicFiles() {
        return _publicFiles;
    }

    public String execute() {
        _publicFiles = User.getPublicFiles();
        return Action.SUCCESS;
    }
}
