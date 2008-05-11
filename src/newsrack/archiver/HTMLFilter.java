package newsrack.archiver;

import newsrack.util.IOUtils;
import newsrack.util.StringUtils;

import org.htmlparser.Parser;
import org.htmlparser.Tag;
import org.htmlparser.Text;
import org.htmlparser.util.ParserException;
import org.htmlparser.visitors.NodeVisitor;
import org.htmlparser.PrototypicalNodeFactory;
import org.htmlparser.tags.MetaTag;
import java.lang.Object;
import java.util.Stack;
import java.util.Hashtable;
import java.io.File;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.PrintWriter;
import java.io.OutputStream;
import java.io.IOException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class HTMLFilter extends NodeVisitor 
{
   	// Logging output for this class
   private static Log _log = LogFactory.getLog(HTMLFilter.class);

	public static final String[] IGNORE_ELTS = {
		"SELECT", "A", "SCRIPT", "STYLE", "MARQUEE",
		"APPLET", "MAP",
// Note: Even though the following tags below are included here,
// they NEED NOT BE included because these are standalone tags.
// They dont come in the form <TAG> ... </TAG>. 
// They come in the form <TAG ... />
// So, the only call to the Visitor will be to "visitTag" --
// there wont be any corresponding call to "visitEndTag"
// But, including them in this list to avoid confusion
//		"AREA", "OPTION", "IMG", "INPUT",
	};

	public static final String[] BLOCK_ELTS = { 
		"P", "DIV", "BLOCKQUOTE",
	};

   public static final String[] RESET_STACK_ELTS = {
      "TABLE", "HTML",
   };

	public static final Hashtable BLOCK_ELTS_TBL;
	public static final Hashtable RESET_ELTS_TBL;
	public static final Hashtable IGNORE_ELTS_TBL;

	static {
		IGNORE_ELTS_TBL = new Hashtable();
		for (int i = 0; i < IGNORE_ELTS.length; i++)
			IGNORE_ELTS_TBL.put(IGNORE_ELTS[i], "");

		BLOCK_ELTS_TBL = new Hashtable();
		for (int i = 0; i < BLOCK_ELTS.length; i++)
			BLOCK_ELTS_TBL.put(BLOCK_ELTS[i], "");

		RESET_ELTS_TBL = new Hashtable();
		for (int i = 0; i < RESET_STACK_ELTS.length; i++)
			RESET_ELTS_TBL.put(RESET_STACK_ELTS[i], "");

		_lineSep = System.getProperty("line.separator");

		org.htmlparser.scanners.ScriptScanner.STRICT = false;	// Turn off strict parsing of cdata
      org.htmlparser.lexer.Lexer.STRICT_REMARKS = false; 	// Turn off strict parsing of HTML comments
	}

	private static String  _lineSep;	// Line separator
   private static boolean _debug = false;

	private Stack        _ignoreFlagStack;
	private String		   _title;
	private StringBuffer _content;
	private String       _url;
	private PrintWriter  _pw;
	private OutputStream _os;
	private boolean      _closeStream;	// Should I close output streams after I am done?
	private boolean      _done;
	private boolean	   _PREtagContent;
	private boolean	   _isTitleTag;
		// Next 3 fields for Newkerala.com hack -- May 18, 2006
	private boolean	   _foundKonaBody;
	private boolean	   _ignoreEverything;
	private Stack        _spanTagStack;
   private boolean      _outputToFile; // Should the content be output to a file?

	private void Init()
	{
		_title            = "";
		_content          = null;
		_done             = false;
		_PREtagContent    = false;
		_isTitleTag       = false;
		_ignoreFlagStack  = new Stack();
		_closeStream      = false;
		_ignoreEverything = false;
		_foundKonaBody    = false;
		_spanTagStack     = new Stack();
      _outputToFile     = true;     // By default, content is written to file!

		Parser.getConnectionManager().setCookieProcessingEnabled(true);
	}
	
	/**
	 * Empty constructor
	 */
	public HTMLFilter() 
	{
		Init();
	}

	/**
	 * @param pw         Print Writer to which filtered HTML should be written
	 **/
	public HTMLFilter(PrintWriter pw)
	{
		Init();
		_pw = pw;
	}

	/**
	 * @param url        URL of the article -- this url will be added in the filtered file
	 *                   as a link to the original article
	 * @param pw         Print Writer to which filtered HTML should be written
	 **/
	public HTMLFilter(String url, PrintWriter pw)
	{
		Init();
		_url = url;
		_pw  = pw;
	}

	/**
	 * @param os         Output Stream to which filtered HTML should be written
	 **/
	public HTMLFilter(OutputStream os)
	{
		Init();
		_os = os;
	}

	/**
	 * @param url        URL of the article -- this url will be added in the filtered file
	 *                   as a link to the original article
	 * @param os         Output Stream to which filtered HTML should be written
	 **/
	public HTMLFilter(String url, OutputStream os)
	{
		Init();
		_url = url;
		_os  = os;
	}

	/**
	 * @param res        File/URL that has to be filtered
	 * @param outputDir  Directory where the filtered file has to be written
	 * @param isURL      True if 'res' is a URL
	 * @throws IOException if there is an error trying to create the output file
	 */
	public HTMLFilter(String res, String outputDir, boolean isURL) throws java.io.IOException
	{ 
		Init();

		char sep;
		if (isURL) {
			_url = res;
			sep = '/';
		}
		else {
			sep = File.separatorChar;
		}
		_pw = IOUtils.getUTF8Writer(outputDir + File.separator + res.substring(1 + res.lastIndexOf(sep)));
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
	public HTMLFilter(String url, String file, String outputDir) throws java.io.IOException
	{ 
		Init();
		_url = url;
		_pw = IOUtils.getUTF8Writer(outputDir + File.separator + file.substring(1 + file.lastIndexOf(File.separatorChar)));
			// Since I have opened these streams, I should close them after I am done!
		_closeStream = true;
	}

	public boolean shouldRecurseSelf() 
	{
		return true;
	} 

	public boolean shouldRecurseChildren() 
	{
		return true;
	}

	public void beginParsing() 
	{
		startDocument();
	}

	private void startDocument() 
	{
		if (!_done) {
			_content = new StringBuffer();
		}
	}

	public void visitTag(Tag tag) 
	{
		String tagName = tag.getTagName();

      if (_log.isDebugEnabled()) _log.debug("ST. TAG - " + tagName + "; name attribute - " + tag.getAttribute("name"));
		if (_debug) System.err.println("ST. TAG - " + tagName + "; name attribute - " + tag.getAttribute("name"));
		if (IGNORE_ELTS_TBL.get(tagName) != null) {
			if (_log.isDebugEnabled()) _log.debug("--> PUSHED");
         if (_debug) System.err.println("--> PUSHED");
			_ignoreFlagStack.push(tagName);
		}
		else if (BLOCK_ELTS_TBL.get(tagName) != null)
			_content.append("\n" + "\n");
		else if (tagName.equals("BR"))
			_content.append("\n");
		else if (tagName.equals("PRE"))
			_PREtagContent = true;
		else if (tagName.equals("TITLE"))
			_isTitleTag = true;
		else if (!_done && tagName.equals("BODY")) {
			// Nothing to do here!
		}
			// Newkerala.com hack -- May 18, 2006
		else if (tagName.equals("SPAN")) {
			String nameAttr = tag.getAttribute("name");
			if ((nameAttr != null) && nameAttr.equals("KonaBody")) {
				_foundKonaBody = true;
				_spanTagStack.push("KONABODY_SPAN");
			}
			else {
				_spanTagStack.push("SPAN");
			}
		}
	}

	public void visitEndTag(Tag tag) 
	{
		String tagName = tag.getTagName();

		if (_log.isDebugEnabled()) _log.debug("END : " + tagName);
		if (_debug) System.err.println("END : " + tagName);

		if (!_ignoreFlagStack.isEmpty() && _ignoreFlagStack.peek().equals(tagName)) {
			if (_log.isDebugEnabled()) _log.debug("--> POPPED");
         if (_debug) System.err.println("--> POPPED");
			_ignoreFlagStack.pop();
		}

/***
 * SSS: Still being tested ... not yet ready for production environment
 *
         // Reset the ignore flag stack whenever these kind of tags are seen.
         // For example, a table closes all mismatched tags, and any pending
         // flags should not be carried over ...
		if (RESET_ELTS_TBL.get(tagName) != null) {
         _ignoreFlagStack = new Stack();
      }
***/

		if (tagName.equals("PRE")) {
			_PREtagContent = false;
		}
		else if (tagName.equals("TITLE")) {
			_isTitleTag = false;
		}
		else if (tagName.equals("HTML")) {
			_done = true;
		}
			// Newkerala.com hack -- May 18, 2006
		else if (!_ignoreEverything && _foundKonaBody && tagName.equals("SPAN")) {
			try {
				Object spanTag = _spanTagStack.pop();
				if (spanTag.equals("KONABODY_SPAN"))
					_ignoreEverything = true;
			}
			catch (Exception e) {
            if (_log.isErrorEnabled()) _log.error("popped out all span tags already! .. empty stack!");
			}
			if (_url != null) {
				if (_url.indexOf("newkerala.com") != -1)
					_content.append("\nCopyright 2001-2005 newkerala.com");
				else if (_url.indexOf("indianexpress.com") != -1)
					_content.append("\n\n&copy; 2006: Indian Express Newspapers (Mumbai) Ltd. All rights reserved throughout the world");
				else if (_url.indexOf("financialexpress.com") != -1)
					_content.append("\n\n&copy; 2006: Indian Express Newspapers (Mumbai) Ltd. All rights reserved throughout the world");
			}
		}
	}

	public void visitStringNode(Text string) 
	{
		String eltContent = string.getText();
		if (_log.isDebugEnabled()) _log.debug("TAG txt - " + eltContent);
		if (_debug) System.err.println("TAG txt - " + eltContent);

			// If this text is coming in the context of a ignoreable tag, discard
		if (!_ignoreFlagStack.isEmpty()) {
			if (_log.isDebugEnabled()) _log.debug(" -- IGNORED");
		   if (_debug) System.err.println(" -- IGNORED");
			return;
		}
			// Newkerala.com hack -- May 18, 2006
		else if (_ignoreEverything) {
			if (_log.isDebugEnabled()) _log.debug(" -- IGNORED");
		   if (_debug) System.err.println(" -- IGNORED");
			return;
		}

		if (_PREtagContent) {
			_content.append(eltContent);
		}
		else if (_isTitleTag) {
			if (_title.equals("")) {
				_title = eltContent;
			}
		}
		else {
			eltContent = collapseWhiteSpace(eltContent);
			if (!isJunk(eltContent)) // skip spurious content!
				_content.append(eltContent);
		}
	}

	public void finishedParsing()
	{
      if (_outputToFile) {
		   printFile(_content);
      }
	}

	private static String collapseWhiteSpace(String s)
	{
		int          n     = s.length();
		char[]       cs    = new char[n];
		StringBuffer sb    = new StringBuffer();
		boolean      ws    = false;
		boolean      empty = true;

		s.getChars(0, n, cs, 0);
		for (int i = 0; i < n; i++) {
			char c = cs[i];
			if (Character.isWhitespace(c) || Character.isSpaceChar(c)) {
				ws = true;
			}
					// &nbsp; is considered white space
			else if ((c == '&')
				   && ((i+5) < n) 
					&& (cs[i+1] == 'n')
					&& (cs[i+2] == 'b')
					&& (cs[i+3] == 's')
					&& (cs[i+4] == 'p')
					&& (cs[i+5] == ';'))
			{
				i += 5;
				ws = true;
			}
			else {
				if (ws) {
					sb.append(' ');
					ws = false;
				}
				else if (empty) {
					sb.append(' ');	// ensure there is white space before content
				}
				empty = false;
				sb.append(c);
			}
		}
		if (!ws)
			sb.append(' ');	// ensure there is white space after content

		return sb.toString();
	}

	private static boolean isJunk(String sb) 
	{
		int     n  = sb.length();
		char[]  cs = new char[n];
		sb.getChars(0, n, cs, 0);
		for (int i = 0; i < n; i++) {
			char c = cs[i];
			if (!Character.isWhitespace(c) && (c != '|') && (c != '-'))
				return false;
		}

		return true;
	}

	private static String prettyPrint(StringBuffer s) 
	{
		// NOTE: In the node visitor methods, I am using "\n" and
		// not _lineSep.  It does not matter, because, in all those
		// methods, "\n" is used as the generic line separator.
		// Before the string is output to a file, in the "prettyPrint"
		// method, "\n"s are being replaced with _lineSep strings.

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
			} 
			else if (Character.isWhitespace(c)) {
				if (!ws) {
					ws = true;
					lastWsPosn = numChars + 1;
				}
			}
			else {
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
				}
				else if (ws) {
					lb.append(' ');
					numChars++;
				}
				ws = false;

				lb.append(c);
				numChars++;
				if (numChars > 75) {
						// If cannot properly break the line, arbitrarily break it!
					if (lastWsPosn == 0)
						lastWsPosn = 75;

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
    * end of the preamble / header in the body text (see code for PrintFile)
    */
   public static String getHTMLTagSignallingEndOfPreamble() { return "h1"; }

	public void printFile(StringBuffer data)
	{
		StringBuffer outBuf = new StringBuffer();
		outBuf.append("<html>" + "\n" + "<head>\n");
		outBuf.append("<title>" + _title + "</title>\n");
			// Set output encoding to UTF-8
		outBuf.append("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n");
		outBuf.append("</head>\n");
		outBuf.append("<body>\n");
		if (_url != null) {
			outBuf.append("<h2 style=\"width:600px; font-size:20px; background:#ffeedd; color: red\">\n");
			outBuf.append("The article was downloaded from:<br/>\n");
			outBuf.append("<a href=\"" + _url + "\">" + _url + "</a></h2>\n");
		}

         // Doing it this way ensures that code in Issue.java (Gen_JFLEX_RegExps) that
         // wants to find the end of the preamble in the output HTML
         // can work even if the tag is changed to something else
      String preambleEndTag = getHTMLTagSignallingEndOfPreamble();
		outBuf.append("<" + preambleEndTag + ">" + _title + "</" + preambleEndTag + ">\n");
		outBuf.append("<pre>\n" + prettyPrint(_content) + "</pre>\n");
		outBuf.append("</body>\n</html>\n");

		if (_pw != null) {
			_pw.println(outBuf);
			_pw.flush();
			if (_closeStream)
				_pw.close();
		}
		else if (_os != null) {
			try {
				_os.write(outBuf.toString().getBytes("UTF-8"));
				_os.flush();
			}
			catch (Exception e) {
            if (_log.isErrorEnabled()) _log.error("Error outputting data to output stream!");
				e.printStackTrace();
			}
		}
	}

	private static void ignoreCharSetChanges(Parser p)
	{
		PrototypicalNodeFactory factory = new PrototypicalNodeFactory ();
		factory.unregisterTag(new MetaTag());
			// Unregister meta tag so that char set changes are ignored!
		p.setNodeFactory (factory);
	}

	private static String parseNow(Parser p, HTMLFilter visitor) throws org.htmlparser.util.ParserException
	{
		try {
         //if (_log.isInfoEnabled()) _log.info("START encoding is " + p.getEncoding());
			p.visitAllNodesWith(visitor);
		}
		catch (org.htmlparser.util.EncodingChangeException e) {
			try {
				if (_log.isInfoEnabled()) _log.info("Caught you! CURRENT encoding is " + p.getEncoding());
				visitor.Init();
				p.reset();
				p.visitAllNodesWith(visitor);
			}
			catch (org.htmlparser.util.EncodingChangeException e2) {
				if (_log.isInfoEnabled()) _log.info("CURRENT encoding is " + p.getEncoding());
				if (_log.isInfoEnabled()) _log.info("--- CAUGHT you yet again! IGNORE meta tags now! ---");
				visitor.Init();
				p.reset();
				ignoreCharSetChanges(p);
				p.visitAllNodesWith(visitor);
			}
		}
		//if (_log.isInfoEnabled()) _log.info("ENCODING IS " + p.getEncoding());
		return p.getEncoding();
	}

	private static Parser filterIt(String fileOrUrl, HTMLFilter visitor) throws Exception
	{
		Parser parser = new Parser(fileOrUrl);
		parseNow(parser, visitor);
		return parser;
	}

	/**
	 * Extract article content from a file and store it on disk
	 * @file    (HTML) File to extract content from
	 * @outDir  Directory where the extracted content should be written to
	 *          Content is stored at "outDir/file"
	 */
	public static void filterFile(String file, String outDir) throws Exception
	{
		filterIt(file, new HTMLFilter(file, outDir, false));
	}

	/**
	 * Extract article content from a file and store it on disk
	 * @file    (HTML) File to extract content from
	 * @pw      Writer to which content should be written to
	 *          NOTE: @pw will NOT be closed.  It is upto the caller to take
	 *          care of closing open streams/writers
	 */
	public static void filterFile(String file, PrintWriter pw) throws Exception
	{
		filterIt(file, new HTMLFilter(pw));
	}

	/**
	 * Extract article content from a file and store it on disk
	 * @file    (HTML) File to extract content from
	 * @os      Output Stream to which content should be written to (always written in UTF-8)
	 *          NOTE: @os will NOT be closed.  It is upto the caller to take
	 *          care of closing open streams/writers
	 */
	public static void filterFile(String file, OutputStream os) throws Exception
	{
		filterIt(file, new HTMLFilter(os));
	}

	/**
	 * Extract article content from a file and store it on disk
	 * @file    (HTML) File to extract content from
	 * @url     URL from where the article was downloaded
	 * @outDir  Directory where the extracted content should be written to
	 *          Content is stored at "outDir/file"
	 */
	public static void filterFile(String url, String file, String outDir) throws Exception
	{
		filterIt(file, new HTMLFilter(url, file, outDir));
	}

	/**
	 * Extract article content from a file and store it on disk
	 * @file    (HTML) File to extract content from
	 * @url     URL from where the article was downloaded
	 * @pw      Writer to which content should be written to
	 *          NOTE: @pw will NOT be closed.  It is upto the caller to take
	 *          care of closing open streams/writers
	 */
	public static void filterFile(String url, String file, PrintWriter pw) throws Exception
	{
		filterIt(file, new HTMLFilter(url, pw));
	}

	/**
	 * Extract article content from a file and store it on disk
	 * @file    (HTML) File to extract content from
	 * @url     URL from where the article was downloaded
	 * @os      Output Stream to which content should be written to (always written in UTF-8)
	 *          NOTE: @os will NOT be closed.  It is upto the caller to take
	 *          care of closing open streams/writers
	 */
	public static void filterFile(String url, String file, OutputStream os) throws Exception
	{
		filterIt(file, new HTMLFilter(url, os));
	}

	/**
	 * Extract article content from a URL and store it on disk
	 * @url     URL from where the article content needs to be extracted
	 * @outDir  Directory where the extracted content should be written to
	 *          Content is stored at "outDir/file" where the last part of
	 *          URL is treated as the output "file".
	 */
	public static void filterURL(String url, String outDir) throws Exception
	{
		filterIt(url, new HTMLFilter(url, outDir, true));
	}

	/**
	 * Extract article content from a URL and store it on disk
	 * @url     URL from where the article content needs to be extracted
	 * @pw      Writer to which content should be written to
	 *          NOTE: @pw will NOT be closed.  It is upto the caller to take
	 *          care of closing open streams/writers
	 */
	public static void filterURL(String url, PrintWriter pw) throws Exception
	{
		filterIt(url, new HTMLFilter(url, pw));
	}

	/**
	 * Extract article content from a URL and store it on disk
	 * @url     URL from where the article content needs to be extracted
	 * @os      OutputStream to write to (always written in UTF-8)
	 *          NOTE: @os will NOT be closed.  It is upto the caller to take
	 *          care of closing open streams/writers
	 */
	public static void filterURL(String url, OutputStream os) throws Exception
	{
		filterIt(url, new HTMLFilter(url, os));
	}

	/**
	 * Extract article content from a URL, store it on disk, and also return
    * the original unfiltered HTML of the article!
	 * @url     URL from where the article content needs to be extracted
	 * @outDir  Directory where the extracted content should be written to
	 *          Content is stored at "outDir/file" where the last part of
	 *          URL is treated as the output "file".
	 */
	public static String filterURLAndGetOrigHTML(String url, String outDir) throws Exception
	{
		Parser p = filterIt(url, new HTMLFilter(url, outDir, true));
		return (p == null) ? null : p.getLexer().getPage().getText();
	}

	/**
	 * Extract article content from a URL and store it on disk
	 * @url     URL from where the article content needs to be extracted
	 * @pw      Writer to which content should be written to
	 *          NOTE: @pw will NOT be closed.  It is upto the caller to take
	 *          care of closing open streams/writers
	 */
	public static String filterURLAndGetOrigHTML(String url, PrintWriter pw) throws Exception
	{
		Parser p = filterIt(url, new HTMLFilter(url, pw));
		return (p == null) ? null : p.getLexer().getPage().getText();
	}

	/**
	 * Extract article content from a URL and store it on disk
	 * @url     URL from where the article content needs to be extracted
	 * @os      OutputStream to which content should be written to (always written in UTF-8)
	 *          NOTE: @os will NOT be closed.  It is upto the caller to take
	 *          care of closing open streams/writers
	 */
	public static String filterURLAndGetOrigHTML(String url, OutputStream os) throws Exception
	{
		Parser p = filterIt(url, new HTMLFilter(url, os));
		return (p == null) ? null : p.getLexer().getPage().getText();
	}

   /**
    * Extract text content from the file and return the content
    * @file  File from which the content needs to be extracted
    */
   public static StringBuffer getFilteredText(String file) throws Exception
   {
      HTMLFilter hf = new HTMLFilter((PrintWriter)null);
      hf._outputToFile = false;
      filterIt(file, hf);
      return hf._content;
   }

   /**
    * Extract text content from a string and returns it
    * @htmlString  String from which the content needs to be extracted
    */
   public static StringBuffer getFilteredTextFromString(String htmlString) throws Exception
   {
      HTMLFilter hf = new HTMLFilter((PrintWriter)null);
      hf._outputToFile = false;
		Parser parser = Parser.createParser(htmlString, "UTF-8");
		parseNow(parser, hf);
      return hf._content;
   }

	public static void main(String[]args) throws ParserException 
	{
		if (args.length == 0) {
			System.out.println("USAGE: java HTMLFilter [-debug] [-o <output-dir>] [(-urllist <file>) OR (-filelist <file>) OR ((-u <url>) OR ([-url <url>] <file>))*]");
			return;
		}

/* Record the output directory, and create it if it doesn't exist */
		int    argIndex = 0;
		String nextArg  = args[argIndex];
		String outDir   = ".";
		if (nextArg.equals("-debug")) {
			_debug = true;
			argIndex++;
			nextArg = args[argIndex];
		}
		if (nextArg.equals("-o")) {
			outDir = args[argIndex + 1];
			argIndex += 2;
			nextArg = args[argIndex];
			File d = new File(outDir);
			if (!d.exists())
				d.mkdir();
		}

			/* Parse the other arguments .. the list of files/urls to be filtered */
		if (nextArg.equals("-filelist") || nextArg.equals("-urllist")) {
			boolean urls = nextArg.equals("-urllist");
			try {
				DataInputStream fileNameStream = new DataInputStream(new FileInputStream(args[argIndex+1]));
				while (true) {
					String line = fileNameStream.readLine();
					if (line == null)
						break;
					try {
						if (urls)
							filterURL(line, outDir);
						else
							filterFile(line, outDir);
					}
					catch (Exception e) {
						System.err.println("ERROR filtering " + line);
						System.err.println("Exception: " + e);
						e.printStackTrace();
					}
				}
			}
			catch (java.io.IOException e) {
				System.err.println("IO exception " + e);
			}
		}
		else {
			for (int i = argIndex; i < args.length; i++) {
				try {
					boolean isUrl  = args[i].equals("-u");
					if (isUrl) {
						filterURL(args[i+1], outDir);
						i++;
					}
					else {
						if (args[i].equals("-url")) {
//							System.out.println("URL - " + args[i+1] + "; fname - " + args[i+2]);
							filterFile(args[i+1], args[i+2], outDir);
							i += 2;
						}
						else {
							filterFile(args[i], outDir);
						}
					}
				}
				catch (Exception e) {
					if (args[i].equals("-u") || args[i].equals("-url"))
						System.err.println("ERROR filtering " + args[i+1]);
					else
						System.err.println("ERROR filtering " + args[i]);
					System.err.println("Exception: " + e);
					e.printStackTrace();
				}
			}
		}
	}
}
