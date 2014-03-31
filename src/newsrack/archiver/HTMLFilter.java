package newsrack.archiver;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.Hashtable;
import java.util.Stack;
import java.util.regex.Pattern;

import org.jsoup.Jsoup;
import org.jsoup.Connection;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.TextNode;
import org.jsoup.nodes.Node;
import org.jsoup.select.NodeTraversor;
import org.jsoup.select.NodeVisitor;
import com.wuman.jreadability.Readability;

import newsrack.NewsRack;
import newsrack.util.IOUtils;
import newsrack.util.StringUtils;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class HTMLFilter {
   	// Logging output for this class
   private static Log _log = LogFactory.getLog(HTMLFilter.class);
	private static String  _lineSep;	// Line separator

	// This walks the DOM and emits readable text
	private static class TextDumper implements NodeVisitor {
		StringBuffer buf;
		TextDumper() { this.buf = new StringBuffer(); }

		public void head(Node n, int depth) {
			if (n instanceof Element) {
				Element e = (Element)n;
				if (e.isBlock()) {
					buf.append("\n\n");
				}
			} else if (n instanceof TextNode) {
				buf.append(((TextNode)n).text());
			}
		}

		public void tail(Node n, int depth) { }

		public String dumpText(Document doc) {
			NodeTraversor t = new NodeTraversor(this);
			t.traverse(doc.body());
			return buf.toString();
		}
	}

	static {
		_lineSep = System.getProperty("line.separator");
	}

   private boolean      _debug; // Debugging?
	private String		   _title;
	private String       _content;
    private String       _url;
	private String       _urlDomain;
	private File         _file;
	private PrintWriter  _pw;
	private OutputStream _os;
	private boolean      _closeStream;	// Should I close output streams after I am done?
   private boolean      _outputToFile; // Should the content be output to a file?

	public Connection setHeaders(Connection c) {
		String ua = NewsRack.getProperty("useragent.string");
		if (ua == null) ua = "NewsRack/1.0 (http://newsrack.in)";
		return c.userAgent(ua).header("Accept-Encoding", "gzip, deflate");
	}

	private void initFilter() {
		_title        = "";
		_content      = null;
		_closeStream  = false;
      _outputToFile = true;     // By default, content is written to file!
		_debug        = false;
	}

	private HTMLFilter() {
		initFilter();
	}

	private void setUrl(String url) {
		_url = url;
		_urlDomain = StringUtils.getDomainForUrl(_url);
	}

	/**
	 * @param url   URL from which HTML was downloaded
	 * @param input File containing HTML to filger
	 * @param os    Output Stream to which filtered HTML should be written
	 **/
	public HTMLFilter(String url, File input, OutputStream os) {
		initFilter();
		_os = os;
		_file = input;
		setUrl(url);
	}

	/**
	 * @param fileOrUrl  File/URL that has to be filtered
	 * @param outputDir  Directory where the filtered file has to be written
	 * @param isURL      True if 'fileOrUrl' is a URL
	 *
	 * @throws IOException if there is an error trying to create the output file
	 */
	public HTMLFilter(String fileOrUrl, String outputDir, boolean isURL) throws java.io.IOException {
		initFilter();

		char sep;
		if (isURL) {
			sep = '/';
			setUrl(fileOrUrl);
		} else {
			_file = new File(fileOrUrl);
			sep = File.separatorChar;
		}
		_pw = IOUtils.getUTF8Writer(outputDir + File.separator + fileOrUrl.substring(1 + fileOrUrl.lastIndexOf(sep)));
		// Since I have opened these streams, I should close them after I am done!
		_closeStream = true;
	}

	/**
	 * @param url        URL of the article -- this url will be added in the filtered file
	 *                   as a link to the original article
	 * @param file       File that has to be filtered
	 * @param outputDir  Directory where the filtered file has to be written
	 * @throws IOException if there is an error trying to create the output file
	 */
	public HTMLFilter(String url, String file, String outputDir) throws java.io.IOException {
		initFilter();
		setUrl(url);
		_file = new File(file);
		_pw = IOUtils.getUTF8Writer(outputDir + File.separator + file.substring(1 + file.lastIndexOf(File.separatorChar)));
			// Since I have opened these streams, I should close them after I am done!
		_closeStream = true;
	}

	public void debug() { _debug = true; }

    private void extractText(Document doc) {
		// Init title
		_title = doc.title();

		// Clean it up!
		Readability r = new Readability(doc);
		r.init();

		// Finally, output new content!
		_content = (new TextDumper()).dumpText(doc);
      if (_outputToFile) outputToFile(_content);
	}

	private Document fetchDoc(String url) throws IOException {
		Connection c = Jsoup.connect(_url);
		Document doc = setHeaders(c).get();
		_url = c.request().url().toString();
		return doc;
	}

	public void run() throws Exception {
		Document doc = null;
		try {
			if (_file != null) {
				doc = Jsoup.parse(_file, null);
			} else {
				doc = fetchDoc(_url);
			}
		} catch (Exception e) {
			String msg = e.toString();
			int    i   = msg.indexOf("no protocol:");
			if (i > 0 && _url != null) {
				String urlSuffix = msg.substring(i + 13);
				_log.info("Got malformed url exception " + msg + "; Retrying with url - " + _urlDomain + urlSuffix);

				// Retry
				fetchDoc(_urlDomain + urlSuffix);
			} else {
				throw e;
			}
		}

		extractText(doc);
	}

	private static String prettyPrint(String s) {
		// NOTE: In the node visitor methods, I am using "\n" and
		// not _lineSep.  It does not matter, because, in all those
		// methods, "\n" is used as the generic line separator.
		// Before the string is output to a file, in the "prettyPrint"
		// method, "\n"s are being replaced with _lineSep strings.

		int          LINE_WIDTH = 75;
		int          n          = s.length();
		char[]       cs         = new char[n];
		StringBuffer lb         = new StringBuffer();
		StringBuffer sb         = new StringBuffer();
		boolean      ws         = false;
		int          numNLs     = 0;
		int          numChars   = 0;
		int          lastWsPosn = 0;

		s.getChars(0, n, cs, 0);
		for (int i = 0; i < n; i++) {
			char c = cs[i];
			if (c == '\n') {
				numNLs++;
			} else if (Character.isWhitespace(c)) {
				if (!ws) {
					ws = true;
					lastWsPosn = numChars + 1;
				}
			} else {
				if (numNLs > 0) {
					lb.append(_lineSep);
					numChars++;
						// Replace 2 or more new lines by exactly 2 new lines
					if (numNLs > 1) {
						lb.append(_lineSep);
						numChars++;
					}
						// Since the line is not junk,
						// append the entire line to 'sb' and clear it out
					sb.append(lb);
					lb.delete(0, numChars);
					numChars = 0;
					lastWsPosn = 0;
					numNLs = 0;
				} else if (ws) {
					lb.append(' ');
					numChars++;
				}
				ws = false;

				lb.append(c);
				numChars++;
				if (numChars > LINE_WIDTH) {
						// If cannot properly break the line, arbitrarily break it!
					if (lastWsPosn == 0) lastWsPosn = LINE_WIDTH;

						// Get the max full words in this line
					String line = lb.substring(0, lastWsPosn - 1);
					sb.append(line);
					sb.append(_lineSep);

						// Get the rest of the line
					String rest = lb.substring(lastWsPosn);

						// Delete everything and retain only the 'rest'
					lb.delete(0, numChars);
					lb.append(rest);
					numChars = rest.length();
					lastWsPosn = 0;
				}
			}
		}

		sb.append(lb);
		sb.append(_lineSep);
		return sb.toString();
	}


   /**
    * Returns the HTML tag that signals the beginning of the body text and
    * end of the preamble / header in the body text (see code for outputToFile)
    */
   public static String getHTMLTagSignallingEndOfPreamble() { return "h1"; }

	private void outputToFile(String data) {
		StringBuffer outBuf = new StringBuffer();
		outBuf.append("<html>" + "\n" + "<head>\n");
		outBuf.append("<title>" + _title + "</title>\n");
			// Set output encoding to UTF-8
		outBuf.append("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n");
		outBuf.append("</head>\n");
		outBuf.append("<body>\n");
		if (_url != null) {
			outBuf.append("<h2 style=\"width:600px; font-size:20px; background:#ffeedd; color: red\">\n");
			outBuf.append("The article was downloaded (and processed) at " + (new java.util.Date()) + " from:<br/>\n");
			outBuf.append("<a href=\"" + _url + "\">" + _url + "</a></h2>\n");
		}

         // Doing it this way ensures that code in Issue.java (Gen_JFLEX_RegExps) that
         // wants to find the end of the preamble in the output HTML
         // can work even if the tag is changed to something else
      String preambleEndTag = getHTMLTagSignallingEndOfPreamble();
		outBuf.append("<" + preambleEndTag + ">" + _title + "</" + preambleEndTag + ">\n");
		outBuf.append("<pre>\n" + prettyPrint(data) + "</pre>\n");
		outBuf.append("</body>\n</html>\n");

		if (_pw != null) {
			_pw.println(outBuf);
			_pw.flush();
			if (_closeStream) _pw.close();
		} else if (_os != null) {
			try {
				_os.write(outBuf.toString().getBytes("UTF-8"));
				_os.flush();
			} catch (Exception e) {
            if (_log.isErrorEnabled()) _log.error("Error outputting data to output stream!");
				e.printStackTrace();
			}
		}
	}

   /**
    * Extract text content from a string and returns it
    * @htmlString  String from which the content needs to be extracted
    */
   public static String getFilteredTextFromString(String htmlString) throws Exception {
      HTMLFilter hf = new HTMLFilter();
      hf._outputToFile = false;
		hf.extractText(Jsoup.parse(htmlString));
      return hf._content;
   }

	public static void main(String[] args) {
		if (args.length == 0) {
			System.out.println("USAGE: java HTMLFilter [-debug] [-o <output-dir>] [(-urllist <file>) OR (-filelist <file>) OR ((-u <url>) OR ([-url <url>] <file>))*]");
			return;
		}

/* Record the output directory, and create it if it doesn't exist */
		int    argIndex = 0;
		String nextArg  = args[argIndex];
		String outDir   = ".";
		boolean debug = false;
		if (nextArg.equals("-debug")) {
			debug = true;
			argIndex++;
			nextArg = args[argIndex];
		}
		if (nextArg.equals("-o")) {
			outDir = args[argIndex + 1];
			argIndex += 2;
			nextArg = args[argIndex];
			File d = new File(outDir);
			if (!d.exists()) d.mkdir();
		}

			/* Parse the other arguments .. the list of files/urls to be filtered */
		if (nextArg.equals("-filelist") || nextArg.equals("-urllist")) {
			boolean urls = nextArg.equals("-urllist");
			try {
				DataInputStream fileNameStream = new DataInputStream(new FileInputStream(args[argIndex+1]));
				while (true) {
					String line = fileNameStream.readLine();
					if (line == null) break;
					try {
						HTMLFilter hf = new HTMLFilter(line, outDir, urls);
						if (debug) hf.debug();
						hf.run();
					} catch (Exception e) {
						System.err.println("ERROR filtering " + line);
						System.err.println("Exception: " + e);
						e.printStackTrace();
					}
				}
			} catch (java.io.IOException e) {
				System.err.println("IO exception " + e);
			}
		} else {
			for (int i = argIndex; i < args.length; i++) {
				try {
					boolean isUrl  = args[i].equals("-u");
					if (isUrl) {
						HTMLFilter hf = new HTMLFilter(args[i+1], outDir, true);
						if (debug) hf.debug();
						hf.run();
						i++;
					} else {
						if (args[i].equals("-url")) {
//							System.out.println("URL - " + args[i+1] + "; fname - " + args[i+2]);
							HTMLFilter hf = new HTMLFilter(args[i+1], args[i+2], outDir);
							if (debug) hf.debug();
							hf.run();
							i += 2;
						} else {
							HTMLFilter hf = new HTMLFilter(args[i], outDir, false);
							if (debug) hf.debug();
							hf.run();
						}
					}
				} catch (Exception e) {
					if (args[i].equals("-u") || args[i].equals("-url")) {
						System.err.println("ERROR filtering " + args[i+1]);
					} else {
						System.err.println("ERROR filtering " + args[i]);
					}
					System.err.println("Exception: " + e);
					e.printStackTrace();
				}
			}
		}
	}
}
