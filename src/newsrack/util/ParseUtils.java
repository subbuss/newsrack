package newsrack.util;

import newsrack.user.User;
import newsrack.filter.UserFile;

import java.io.Reader;
import java.lang.System;
import java.util.Hashtable;
import java.util.LinkedList;
import java.util.Iterator;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.ErrorHandler;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * This class provides auxilliary functionality to
 * - parse XML files into the DOM model, 
 * - traverse the DOM tree
 * - record parsing errors
 * This functionality is not part of the API of the existing org.w3c.dom.* classes.
 *
 * @author  Subramanya Sastry
 */
public final class ParseUtils
{
	private static class NewsRackXMLErrorHandler implements ErrorHandler
	{
		public NewsRackXMLErrorHandler() { }

		public void error(SAXParseException e) throws SAXException
		{ 
			System.err.println("Parse Error: " + e);
			throw e;
		}

		public void fatalError(SAXParseException e) throws SAXException
		{ 
			System.err.println("Parse Fatal Error: " + e);
			throw e;
		}

		public void warning(SAXParseException e) throws SAXException
		{ 
			System.err.println("Parse Warning: " + e);
		}
	}

	private static Hashtable               _errTable = new Hashtable();
	private static NewsRackEntityResolver  _er       = new NewsRackEntityResolver();
	private static NewsRackXMLErrorHandler _eh       = new NewsRackXMLErrorHandler();

	/** This method keeps track of parsing errors.
    * At a later time, all parse errors can be retrieved.
	 *
    * @param f        The file being parsed
	 * @param lineNum  Line Number where error occurred
    * @param msg      The error message
    */
	public static void parseError(UserFile f, int lineNum, String msg)
	{
		StringUtils.error(msg);

			/* Record error */
		User u = f._user;
		if (u != null) {
			LinkedList errs = (LinkedList)_errTable.get(u);
			if (errs == null) {
				errs = new LinkedList();
				_errTable.put(u, errs);
			}
			errs.add("[File <span class=\"filename\">" + f._name + ":</span> Line Number: <span class=\"linenum\">" + lineNum + "</span>]: " + msg);
		}
	}

	/** This method keeps track of parsing errors.
    * At a later time, all parse errors can be retrieved.
	 *
    * @param f      The file being parsed
    * @param msg    The error message
    */
	public static void parseError(UserFile f, String msg)
	{
		StringUtils.error(msg);

			/* Record error */
		User u = f._user;
		if (u != null) {
			LinkedList errs = (LinkedList)_errTable.get(u);
			if (errs == null) {
				errs = new LinkedList();
				_errTable.put(u, errs);
			}
			errs.add("ERROR parsing file <span class=\"filename\">" + f._name + "</span>: " + msg);
		}
	}

	/** This method keeps track of parsing errors.
    * At a later time, all parse errors can be retrieved.
	 *
    * @param u      The user whose files are being parsed
    * @param msg    The error message
    */
	public static void parseError(User u, String msg)
	{
		StringUtils.error(msg);

			/* Record error */
		if (u != null) {
			LinkedList errs = (LinkedList)_errTable.get(u);
			if (errs == null) {
				errs = new LinkedList();
				_errTable.put(u, errs);
			}
			errs.add("ERROR parsing profile! [" + msg + "]");
		}
	}

	/** This method checks if there were parsing errors while validating 
	 * a user's profile.
	 *
    * @param u  The user for whom the check should be made
    */
	public static boolean encounteredParseErrors(User u)
	{
		return _errTable.containsKey(u);
	}

	/** This method gets all parsing errors for a user. The error
	 * list is cleared after it is returned.
	 *
    * @param u  The user for whom parse errors should be retrieved.
    */
	public static Iterator getParseErrors(User u)
	{
		LinkedList ll = (LinkedList)_errTable.get(u);
		if (ll == null) {
			return null;
		}
		else {
			_errTable.remove(u);
			return ll.iterator();
		}
	}
	
	/** This method reads an XML file and returns a parsed DOM document 
	  * It exits if there is any error reading/parsing the XML file.
     *
     * @param r          Reader for the XML file that needs to be read
	  * @param validating Will this be a validating parser?
     */
	public static Document getParsedDocument(Reader r, boolean validating) throws Exception
	{
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		factory.setValidating(validating);
		factory.setIgnoringElementContentWhitespace(true);
		factory.setIgnoringComments(true);
		DocumentBuilder db = factory.newDocumentBuilder();
		db.setEntityResolver(_er);
		db.setErrorHandler(_eh);
			// By using input readers (rather than streams), we allow
			// file-specific encodings to be used.
		return db.parse(new InputSource(r));
	}

	public static Document getParsedDocument(Reader r) throws Exception
	{
		return getParsedDocument(r, true);
	}

	/** This method reads an XML file and returns a parsed DOM document 
	  * It exits if there is any error reading/parsing the XML file.
     *
     * @param f   the XML file that needs to be read
     */
	public static Document getParsedDocument(UserFile f) throws Exception
	{
		try {
			System.out.println("--> Parsing file " + f._name);
				// By using input readers (rather than streams), we allow
				// file-specific encodings to be used.
			return getParsedDocument(f.getFileReader());
		}
		catch (Exception e) {
			System.out.println("exception: " + e);
			e.printStackTrace();
			throw new Exception("Exception while parsing file <b>" + f._name + "</b><br>" + e.toString().replaceAll("<", "&lt;").replaceAll(">","&gt;"));
		}
	}

	/** This method reads an XML file and returns a parsed DOM document 
	  * It exits if there is any error reading/parsing the XML file.
     *
     * @param f   the name of the XML file that needs to be read
     */
	public static Document getParsedDocument(String f, boolean validating) throws Exception
	{
		try {
			System.out.println("--> Parsing file " + f);
				// By using input readers (rather than streams), we allow
				// file-specific encodings to be used.
			return getParsedDocument(IOUtils.getUTF8Reader(f), validating);
		}
		catch (Exception e) {
			System.out.println("exception: " + e);
			e.printStackTrace();
			throw new Exception("Exception while parsing file <b>" + f + "</b><br>" + e.toString().replaceAll("<", "&lt;").replaceAll(">","&gt;"));
		}
	}

	/** This method recursive traverses a DOM document node and prints
	  * it to standard output.  This is an internal method of the class
	  * for the purpose of debugging.
     *
     * @param n       Node to be printed
     */
	public static void print(Node n)
	{
		if (n.getNodeType() == Node.ELEMENT_NODE)
			System.out.println("<" + n.getNodeName() + ">");
		else if (n.getNodeType() == Node.TEXT_NODE)
			System.out.println("\"" + n.getNodeValue() + "\"");

		if (n.hasChildNodes()) {
			NodeList sls = n.getChildNodes();
			int      num = sls.getLength();
			for (int i = 0; i < num; i++)
				print(sls.item(i));
		}

		if (n.getNodeType() == Node.ELEMENT_NODE)
			System.out.println("</" + n.getNodeName() + ">");
	}

	/** This method returns all the children of a node that match a
	  * specified tag.  This method only looks at the children of the
	  * specified node whereas "Element.getElementsByTagName" looks
	  * all nodes in a preorder traversal of the document tree rooted
	  * at the specified node
     *
     * @param n       Node to be examined
     * @param tag     Tag that has to be searched
     */
	public static Iterator getChildrenByTagName(Node n, String tag)
	{
		return new MatchingChildrenIterator(n, tag);
	}

	/** This method returns the only child of a node that matches a
	  * specified tag.  If multiple children with the same tag are found,
	  * only the first child is accepted.  The other children are ignored.
	  * This method prints an error message onto standard output.
     *
     * @param n       Node to be examined
     * @param tag     Tag that has to be searched
     */
	public static Node getOnlyChildByTagName(Node n, String tag)
	{
		Iterator it     = new MatchingChildrenIterator(n, tag);
		Node     retVal = (it.hasNext()) ? ((Node)it.next()) : null;
		if (it.hasNext())
			System.out.println("Only one <" + tag + "> element is accepted.  Accepting only the first.");

		return retVal;
	}

	/**
	 * The class <code>MatchingChildrenIterator</code> implements
	 * the iterator interface and provides an iterator over all the
	 * children of a DOM Node 'n' that have a tag 't'.
	 *
	 * @author  Subramanya Sastry
	 * @version 1.0 03/05/04
	 */
	private static final class MatchingChildrenIterator implements Iterator
	{
		private Node   _curr;
		private String _tag;

		private void moveToNextMatch()
		{
			while (_curr != null) {
				if (_curr.getNodeName().equals(_tag))
					break;
				_curr = _curr.getNextSibling();
			}
		}

		public MatchingChildrenIterator(Node n, String tag) 
		{ 
			_tag  = tag;
			_curr = n.getFirstChild(); 
			moveToNextMatch();
		}

		public Object next()
		{
			Node retVal = _curr;
			_curr = _curr.getNextSibling();
			moveToNextMatch();
			return retVal;
		}

		public boolean hasNext() { return (_curr != null); }
		public void    remove()  { throw new UnsupportedOperationException(); }
	}
}
