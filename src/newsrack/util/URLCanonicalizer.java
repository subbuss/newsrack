package newsrack.util;

import newsrack.NewsRack;

import java.util.HashMap;
import java.util.Hashtable;
import java.util.regex.Pattern;

import org.htmlparser.http.ConnectionManager;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

// This class takes urls of news stories so that we can more easily
// recognize identical urls.  For now, this class hardcodes rules
// for a few sites.  In future, this information should come from
// an external file that specifies match-rewrite rules for urls
public class URLCanonicalizer
{
   static Log _log = LogFactory.getLog(URLCanonicalizer.class);

	static ConnectionManager cm;

		/* These are patterns for detecting feed proxies */
	static String[] proxyREStrs = new String[] { 
		"^feeds\\..*$", "^feedproxy\\..*$", "^.*\\.feedburner.com$", "^pheedo.com$"
	};

		/* Domains & corresponding url-split rule */
	static String[] urlFixupRuleStrings = new String[] {
      "sfgate.com:&feed=.*", "marketwatch.com:&dist=.*", "bloomberg.com:&refer=.*", "cbsnews.com:\\?source=[^?&]*",
		"vaildaily.com:\\/-1\\/rss.*", "news.newamericamedia.org:&from=.*"
   };

   	/* Domains for which we'll replace all ?.* url-tracking parameters */
	static String[] domainsWithDefaultFixupRule = new String[] {
		"nytimes.com", "rockymountainnews.com",
		"newscientist.com", "washingtonpost.com", "guardian.co.uk",
		"boston.com", "publicradio.org", "cnn.com", "chicagotribune.com",
		"latimes.com", "twincities.com", "mercurynews.com", "wsj.com",
		"seattletimes.nwsource.com", "reuters.com", "sltrib.com"
   };

	static Pattern[] proxyREs;
	static HashMap<String,Pattern> urlFixupRules;

	static {
			// Set up some default connection properties!
		Hashtable headers = new Hashtable();
		String ua = NewsRack.getProperty("useragent.string");
		if (ua == null) ua = "NewsRack/1.0 (http://newsrack.in)";
		headers.put ("User-Agent", ua);
      headers.put ("Accept-Encoding", "gzip, deflate");

			// Turn off automatic redirect processing
		java.net.HttpURLConnection.setFollowRedirects(false);

			// Set up a connection manager to follow redirects while using cookies
		cm = new ConnectionManager();
		cm.setRedirectionProcessingEnabled(true);
		cm.setCookieProcessingEnabled(true);
		cm.setDefaultRequestProperties(headers);

			// Compile proxy domain patterns 
		proxyREs = new Pattern[proxyREStrs.length];
		int i = 0;
		for (String re: proxyREStrs) {
			proxyREs[i] = Pattern.compile(re);
			i++;
		}

			// Custom url fixup rules
		urlFixupRules = new HashMap<String, Pattern>();
		for (String s: urlFixupRuleStrings) {
			String[] x = s.split(":");
			urlFixupRules.put(x[0], Pattern.compile(x[1]));
		}
	}

	private static String getDomain(String url)
	{
		url = url.replace("http://", "");
		return url.substring(0, url.indexOf("/")).replace("www.", "");
	}

	private static boolean isFeedProxyUrl(String url)
	{
		String d = getDomain(url);
		if (_log.isDebugEnabled()) _log.debug("Domain: " + d);
		for (Pattern p: proxyREs) {
			if (p.matcher(d).matches()) {
				if (_log.isDebugEnabled()) _log.debug("PATTERN " + p.pattern() + " succeeded");
				return true;
			}
			else {
				if (_log.isDebugEnabled()) _log.debug("PATTERN " + p.pattern() + " failed");
			}
		}

		return false;
	}

	public static String cleanup(String baseUrl, String url)
	{
			// get rid of all white space!
		url = url.replaceAll("\\s+", "");
			// Is this allowed in the spec??? Some feeds (like timesnow) uses relative URLs!
		if (url.startsWith("/"))
			url = baseUrl + url;

		return url;
	}

	private static String getTargetUrl(String url)
	{
		try {
			java.net.URLConnection conn = cm.openConnection(new java.net.URL(url));
			String newUrl = conn.getURL().toString();
			if (conn instanceof java.net.HttpURLConnection)
				((java.net.HttpURLConnection)conn).disconnect();
         else
            _log.error("Connection is not a HttpURLConnection!");
			return newUrl;
		}
		catch (Exception e) {
			String msg = e.toString();
			int    i   = msg.indexOf("no protocol:");
			if (i > 0 && url != null) {
				String domain    = url.substring(0, url.indexOf("/", 7));
				String urlSuffix = msg.substring(i + 13);
				String newUrl    = domain + urlSuffix;
				_log.info("Got malformed url exception " + msg + "; Retrying with url - " + newUrl);
				return getTargetUrl(newUrl);
			}
			else {
				if (_log.isDebugEnabled()) _log.debug("Got exception: " + e);
				return url;
			}
		}
	}

	public static String canonicalize(String url)
	{
		boolean repeat;
		do {
		   repeat = false;

				// Special rule for news.google.com
			if (url.indexOf("news.google.com/") != -1) {
				int proxyUrlStart = url.lastIndexOf("http://");
				if (proxyUrlStart != -1) {
					url = url.substring(proxyUrlStart);
					url = url.substring(0, url.lastIndexOf("&cid="));
				}
			}

				// Follow proxies
			if (isFeedProxyUrl(url))
				url = getTargetUrl(url);

			String domain = getDomain(url);
			if (_log.isDebugEnabled()) _log.debug("Domain for default rule: " + domain);

			Pattern p = urlFixupRules.get(domain);
			if (p != null) {
					// Default fixup rule
				if (_log.isDebugEnabled()) _log.debug("Found a pattern: " + p.pattern());
				String newUrl = p.split(url)[0];
				if (!newUrl.equals(url))
					url = newUrl;
			}
			else {
					// Default fixup rule
				for (String d: domainsWithDefaultFixupRule) {
					if (domain.indexOf(d) != -1) {
						int i = url.indexOf("?");
						if (i > 0) {
							url = url.substring(0, i);
						}
						break;
					}
				}
			}

				// Do not use 'else if'
			if (!url.startsWith("http://uni.medhas.org")) {
				url = url.substring(url.lastIndexOf("http://"));
			}
		} while(repeat);

		return url;
	}

	public static void main(String[] args)
	{
		System.out.println("input - " + args[0] + "; output - " + canonicalize(args[0]));
	}
}
