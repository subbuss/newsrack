package newsrack.web;

import newsrack.GlobalConstants;
import newsrack.user.User;
import java.io.IOException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;

/**
 * class <code>ReclassifyAction</code> implements the functionality
 * of reclassifying news from the archive.
 */

public class ReclassifyAction extends BaseAction
{
   private static final Log _log = LogFactory.getLog(ReclassifyAction.class); /* Logger for this action class */

   public String execute()
   {
			// Should all dates be used?
		boolean allDates    = false;
		String  allDatesOpt = getParam("completeArchive");
		if ((allDatesOpt != null) && allDatesOpt.equals("on"))
			allDates = true;

			// Should all sources be used?
		boolean allSrcs         = false;
		String  allSrcsOpt = getParam("allSources");
		if ((allSrcsOpt != null) && allSrcsOpt.equals("on"))
			allSrcs = true;

			// Should categories be reset?
		boolean resetCats = false;
		String  resetOpt  = getParam("resetCats");
		if ((resetOpt != null) && resetOpt.equals("on"))
			resetCats = true;

			// What issue to reclassify?
		String issue = getParam("issue");

			// Find sources to reclassify from
		String srcs[] = getParamValues("srcs");

			// Get start and end dates
		String sd = getParam("sd");
		String sm = getParam("sm");
		String sy = getParam("sy");
		String ed = getParam("ed");
		String em = getParam("em");
		String ey = getParam("ey");
		if (sd.length() == 1) sd = "0" + sd;
		if (sm.length() == 1) sm = "0" + sm;
		if (ed.length() == 1) ed = "0" + ed;
		if (em.length() == 1) em = "0" + em;
		String sdate = sy + sm + sd;
		String edate = ey + em + ed;
		try {
			if (_log.isInfoEnabled())
				_log.info("Request for reclassification at: " + (new java.util.Date()));

				// Display success message
			if ((issue != null) && (((srcs != null) && (srcs.length != 0)) || allSrcs)) {
				_user.reclassifyNews(issue, srcs, allSrcs, sdate, edate, allDates, resetCats);
				return Action.SUCCESS;
			}
			else {
				_log.error("NO issue/sources specified for reclassification!");
				return Action.ERROR;
			}
		}
		catch (Exception e) {
			_log.error("Error reclassifying news!", e);
			return Action.ERROR;
		}
	}
}
