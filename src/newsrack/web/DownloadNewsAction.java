package newsrack.web;

import com.opensymphony.xwork2.Action;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * class <code>DownloadNewsAction</code> implements the functionality
 * of downloading the latest news.
 */
public class DownloadNewsAction extends BaseAction {
    private static final Log log = LogFactory.getLog(DownloadNewsAction.class); /* Logger for this action class */

    public String execute() {
        try {
            _user.downloadNews();
            return Action.SUCCESS;
        } catch (Exception e) {
            log.error("Error downloading news!", e);
            return Action.ERROR;
        }
    }
}
