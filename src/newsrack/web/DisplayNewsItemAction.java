package newsrack.web;

import newsrack.user.User;
import newsrack.database.NewsItem;
import newsrack.archiver.Source;

import java.io.IOException;
import java.io.Reader;
import javax.servlet.http.HttpServletResponse;

import com.opensymphony.xwork2.Action;

import org.apache.struts2.interceptor.ServletResponseAware;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * class <code>DisplayNewsItemAction</code> implements the functionality
 * of displaying the local copy of a news item.
 */
public class DisplayNewsItemAction extends BaseAction implements ServletResponseAware
{
   private static final Log _log = LogFactory.getLog(DisplayNewsItemAction.class); /* Logger for this action class */

		// ServletResponseAware
   private HttpServletResponse _response;
   public void setServletResponse(HttpServletResponse r) { _response = r; }

		// Values needed by the UI
	private NewsItem _ni;
	private String   _body;

	public NewsItem getNewsItem() { return _ni; }
	public String   getBody() { return _body; }

   public String execute()
	{
/* FIXME: later on, check if this news item is in the "public domain"
 * but for now, all news display is public, to allow for guest browsing
 * of publicly available issues of registered users
 */
		String niPath = null;
		try {
			niPath = getParam("ni");
			if (niPath == null) {
				_log.error("News item path not specified");
				return Action.ERROR;
			}
			else {
				_ni = Source.getNewsItemFromLocalCopyPath(niPath);
				Reader       fr   = _ni.getReader();
				StringBuffer csb  = new StringBuffer();
				char[]       cbuf = new char[256];
				while (fr.read(cbuf) != -1) {
					csb.append(cbuf);
				}
				fr.close();

/* FIXME: The code below assumes a particular structure of the HTML file .. Perhaps should ask
 * newsrack.util.HTMLFilter to handle this functionality so that everything remains consistent!  */
				String sb = csb.toString();
				int    bb = sb.indexOf("<pre>");
				int    be = sb.indexOf("</pre>");
				_body  = sb.substring(bb+5, be);
				return Action.SUCCESS;
			}
		}
		catch (Exception e) {
			_log.error("Error displaying news item - " + niPath, e);
			addActionError(getText("error.news.display"));
			try {
				_response.sendError(HttpServletResponse.SC_GONE, "Sorry! The news item has been moved and the new location is not known!");
			}
			catch (Exception ee) {
				_log.error("HMM!! Could not send 410 error message to client in response to request for news item " + niPath);
			}

			return null;
		}
	}
}
