package newsrack.web;

import com.opensymphony.xwork2.Action;
import newsrack.archiver.Feed;
import newsrack.archiver.Source;
import newsrack.filter.NR_SourceCollection;
import newsrack.user.User;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

/**
 * class <code>MiscAction</code> implements miscellaneous functionality
 */

public class MiscAction extends BaseAction
{
   private static Log _log = LogFactory.getLog(MiscAction.class);	// Logger for this action class

	private static List<Feed> _indianFeeds = null;
	public List<Feed> getIndianFeeds() { return _indianFeeds; }

	public static void cacheKnownIndianFeeds() {
		// SSS: Hardcoded for newsrack.in install
		User libraryUser = User.getUser("library");
		Collection srcs = ((NR_SourceCollection)libraryUser.getSourceCollection("Indian News Media Feeds")).getSources();
		_indianFeeds = new ArrayList<Feed>();
		for (Object o: srcs) {
			_indianFeeds.add(((Source)o).getFeed());
		}
      Collections.sort(_indianFeeds);
	}

   public String knownIndianFeeds()
	{
		// Cached
		if (_indianFeeds == null) cacheKnownIndianFeeds();
		return Action.SUCCESS;
	}
}
