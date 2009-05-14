package newsrack.web.api;

import newsrack.web.BaseAction;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class BaseApiAction extends BaseAction
{
   protected static Log _log = LogFactory.getLog(BaseApiAction.class);
	protected String _errMsg;

	public String getErrorMsg() { return _errMsg; }

	protected String getApiParamValue(String paramKey, boolean optional)
	{
		String val = getParam(paramKey);
		if (val == null) {
			if (!optional) {
				_errMsg = getText("error.api.no." + paramKey);
				_log.error("API: " + _errMsg);
			}
		}
		return val;
	}

	protected boolean validateParam(Object o, String paramKey, String paramValue)
	{
		if (o == null) {
			_errMsg = getText("error.api.bad." + paramKey, new String[] {paramValue});
			_log.error("API: Unknown " + paramKey + ":" + paramValue);
			return false;
		}
		else {
			return true;
		}
	}

	protected String apiSuccess()
	{
			// Done -- XML or JSON!
		String outType = getParam("output");
		return (outType == null) ? "xml" : outType;
	}
}
