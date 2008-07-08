package newsrack.web.api;

import newsrack.filter.Issue;
import newsrack.filter.Category;
import newsrack.user.User;
import newsrack.database.NewsItem;
import newsrack.web.BaseAction;

import java.io.IOException;
import java.util.Date;
import java.util.List;
import java.text.SimpleDateFormat;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * class <code>GetNewsAction</code> implements the functionality of fetching news
 *
 * Ex: GET /api/news?<PARAMS>
 * . user=UID
 * . issue=ISSUE
 * . catId=ID
 * . source=SOURCE
 * . start_date=START
 * . end_data=END
 * . start=N
 * . count=N (max = 100)
 */
public class GetNewsAction extends BaseApiAction
{
   private static final ThreadLocal<SimpleDateFormat> DATE_PARSER = new ThreadLocal<SimpleDateFormat>() {
		protected SimpleDateFormat initialValue() { return new SimpleDateFormat("yyyy.mm.dd"); }
	};

	private List<NewsItem> _news;
	public List<NewsItem> getNews() { return _news;}

   public String execute()
	{
		try {
				// User - mandatory
			String uid = getApiParamValue("user", false);
			User   u   = (uid == null) ? null: User.getUser(uid);
			if (!validateParam(u, "user_name", uid))
				return Action.ERROR;

				// Issue - mandatory
			String issueName = getApiParamValue("issue", false);
			Issue  i         = (issueName == null) ? null : u.getIssue(issueName);
			if (!validateParam(i, "issue_name", issueName))
				return Action.ERROR;

				// Cat Id - optional
			Category c = null;
			String catId = getApiParamValue("catId", true);
			if (catId != null) {
				c = i.getCategory(Integer.parseInt(catId));
				if (!validateParam(c, "cat_id", catId))
					return Action.ERROR;
			}

				// start - optional
			int start = -1;
			String startStr = getApiParamValue("start", true);
			if (startStr != null)
				start = Integer.parseInt(startStr);
			if (start < 0)
				start = 0;

				// count - optional
			int count = -1;
			String countStr = getApiParamValue("count", true);
			if (countStr != null)
				count = Integer.parseInt(countStr);
			if (count > 100)
				count = 100;
			if (count < 0)
				count = 20;

				// start date - optional
			Date startDate = null;
			String sdStr = getApiParamValue("start_date", true);
			if (sdStr != null) {
				try {
					startDate = DATE_PARSER.get().parse(sdStr);
				}
				catch (Exception e) {
					_errMsg = getText("api.bad.date", sdStr);
					_log.error("Error parsing date: " + sdStr, e);
					return Action.ERROR;
				}
			}

				// end date - optional
			Date endDate = null;
			String edStr = getApiParamValue("end_date", true);
			if (edStr != null) {
				try {
					endDate = DATE_PARSER.get().parse(edStr);
				}
				catch (Exception e) {
					_errMsg = getText("api.bad.date", edStr);
					_log.error("Error parsing date: " + edStr, e);
					return Action.ERROR;
				}
			}

				// Set up news
			_news = (c == null) ? i.getNews(startDate, endDate, start, count)
			                    : i.getNews(startDate, endDate, start, count);

				// Done -- XML or JSON!
			String outType = getParam("outputType");
			return (outType == null) ? "xml" : outType;
		}
		catch (Exception e) {
			_log.error("API: GetNews: Error fetching news!", e);
			return Action.ERROR;
		}
	}
}
