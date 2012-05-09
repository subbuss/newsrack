package newsrack.filter;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import newsrack.util.StringUtils;

/**
 * The class <code>Concept</code> represents a concept which is
 * a collection of keywords, a match of any of which will trigger
 * the match of the concept.
 *
 * Let $plural = s
 * For each keyword $k (after trimming leading and trailing whitespace),
 * the following rules apply with respect to matching:
 *    1. $k$plural will also be matched.
 *    2. ' ' will match one or more white space characters
 *    3. '-' will match a '-', if any, and white space, if any.
 *       Ex: multi-national will match multinational, multi-national
 *           multi  national, multi - national
 * &lt;/pre&gt;
 *
 * @author  Subramanya Sastry
 * @version 2.0 10th November 2006
 */
public class Concept implements java.io.Serializable
{
// ############### STATIC FIELDS AND METHODS ############

	public final static boolean _debugging = false;

	private static String genScanTokenName(final String tok)
	{
		return tok.replace('-', '_').replaceAll(":","__");
	}

	public static void main(final String[] args)
	{
		if (args.length == 0) {
			System.out.println("Usage: java Concept <concept.xml>");
			System.exit(0);
		}
	}

// ############### NON-STATIC FIELDS AND METHODS ############
			// (_collection, _name) uniquely identifies the concept
	private Long    _key;			// Database key
	private String	 _name;			// Name of the concept
	private String  _defnString;	// Definition string for the concept
	private List<String>         _keywords;	 // Keywords that specify the concept
	private NR_ConceptCollection _collection;// Collection that this concept belongs to
	private ConceptToken _lexerToken;	// Concept token for the lexer

	private int copyPredefinedKeyword(final StringBuffer re, int i, final char[] cs)
	{
			// This is a newsrack predefined keywords
			// Read in the entire keyword as is without changes
		final StringBuffer buf = new StringBuffer();
		char c;
		i++;
		while (true) {
			c = cs[i];
			i++;
			if (c == ']')
				break;
			buf.append(c);
		}
		final String kw   = buf.toString();
		final String kwRE = (String)Issue.PREDEFINED_KEYWORDS.get(kw);
		if (kwRE == null)
			StringUtils.error("In the definition of concept " + _name + ", unknown macro " + kw);
		re.append("[" + buf + "]");
		return i;
	}

	/**
	 * This method normalizes <keyword>s:
	 * - Collapses multiple adjacent white space characters
	 * - Collapses multiple adjacent hyphen characters
	 * - It recognizes special characters if any and eliminates them 
	 *   by generating all possible key-phrases that might by matched
	 *   by the <keyword>.
	 * 
	 * I18N FIXME: This method works only for English
	 */
	private void normalizeKeyword(String s)
	{
		// Collapse multiple adjacent
		// (a) white space characters
		// (b) hyphen characters
		int          n   = s.length();
		StringBuffer ns  = new StringBuffer();
		char[]       cs  = s.toCharArray();
		boolean      ws  = false;
		boolean      hyp = false;
		boolean      pp  = false;	// Should I post-process the keyword?

		for (int i = 0; i < n; i++) {
			final char c = cs[i];
			if (Character.isSpaceChar(c)) {
				hyp = false;
				if (!ws) {
					ws = true;
						// Replace any generic sequence of white-space characters with ' '
					ns.append(' ');
				}
			}
			else if (c == '-') {
					/* If I see a hyphen, then the keyword has to be post-processed
					 * to include all possible matches because '-' has special meaning
					 *    '-' will match a '-', if any, and white space, if any.
					 *    Ex: multi-national will match multinational, multi-national
					 *        multi  national, multi - national */
				pp = true;

				ws  = false;
				if (!hyp) {
					hyp = true;
					ns.append(c);
				}
			}
			else if (c == '[') {
				ws  = false;
				hyp = false;
				i = copyPredefinedKeyword(ns, i, cs);
			}
			else {
				ws  = false;
				hyp = false;
				ns.append(c);
			}
		}

			/* Now, normalize the <keyword> by getting rid of all
			 * special characters and replacing them with explicit keyphrases
			 * that are implied by the special character
			 * Ex: If I see a hyphen, then the keyword has to be post-processed
			 * to include all possible matches because '-' has special meaning
			 *    '-' will match a '-', if any, and white space, if any.
			 *    Ex: multi-national will match multinational, multi-national
			 *        multi  national, multi - national */
		if (pp) {
			s   = ns.toString();
			n   = s.length();
			cs  = s.toCharArray();

			List         kws = new LinkedList();
			StringBuffer buf = new StringBuffer();

			for (int i = 0; i < n; i++) {
				final char c = cs[i];
				if (c == '-') {
						/*
						 * '-' in a <keyword> means '', ' ', or '-'
						 * So, the number of key-phrases is 3^n where 
						 * n is the number of occurences of '-' in the <keyword>
						 */
					final String ss = buf.toString();
					if (kws.isEmpty()) {
						kws.add(ss);
						kws.add(ss + " ");
						kws.add(ss + "-");
					}
					else {
							/* Add the 3 combinations for every sub-string */
						final List     nkws = new LinkedList();
						final Iterator it   = kws.iterator(); 
						while (it.hasNext()) {
							s = (String)it.next();
							nkws.add(s + ss);
							nkws.add(s + ss + " ");
							nkws.add(s + ss + "-");
						}
						kws = nkws;
					}
						// Reset buf -- to identify the next substring
						// after the '-' in the <keyword>
					buf = new StringBuffer(); 
				} else
					buf.append(c);
			}

				// Add the rest of the string to the end!
			final String   ss   = buf.toString();
			final List     nkws = new LinkedList();
			Iterator it   = kws.iterator(); 
			while (it.hasNext()) {
				s = (String)it.next();
				nkws.add(s + ss);
			}
			kws = nkws;

				// For every possible keyword, add it and
				// its plural to the list!
			it = kws.iterator(); 
			while (it.hasNext()) {
				s = (String)it.next();
				_keywords.add(s);
				final String sp = StringUtils.pluralize(s);
				if (sp != null) _keywords.add(sp);
			}
		}
		else {
			s = ns.toString();
			_keywords.add(s);
			final String sp = StringUtils.pluralize(s);
			if (sp != null) _keywords.add(sp);
		}
	}

	public Concept(final String name, final List kws)
	{
		_key      = null;
		_name     = name;
		_lexerToken = null;
		_keywords = new ArrayList<String>();

		StringBuffer defn = new StringBuffer();
		for (final Iterator it = kws.iterator(); it.hasNext(); ) {
			final Object o = it.next();
			if (o instanceof String) {
				defn.append(o);

				final String kw = (String)o;
				if (kw.startsWith("-")) {
					/** FIXME: ... Add this to the list of ignore keywords ... **/
				} 
				else if (kw.length() > 0) {
					normalizeKeyword(kw);
				}
				else {
					// ParseUtils.ParseError("Zero length keyword");
				}
			}
			else /* o instanceof Concept */ {
				final Concept c = (Concept)o;
				defn.append("<" + c.getName() + ">");
				_keywords.addAll(c._keywords);
			}

				// Add a ","
			if (it.hasNext())
				defn.append(", ");
		}

		//@ fixme: Need to get this from the parser directly!
		_defnString = defn.toString();
	}

	public Concept(final String name, final String defnString)
	{
		_name       = name;
		_defnString = defnString;
	}

	public boolean equals(Object o)
	{
		if ((o != null) && (o instanceof Concept)) {
			Concept c = (Concept)o;
			return c._collection.equals(_collection) && c._name.equals(_name);
		}
		else {
			return false;
		}
	}

	public int hashCode() { return _name.hashCode() * 31 + _collection.hashCode() * 31; }

	/**
	 * This method prints the concept along with the
	 * keywords that specify it.
	 */
	public String toString()
	{
		final StringBuffer sb = new StringBuffer(_name + ":\n");
		final Iterator     it = _keywords.iterator();
		while (it.hasNext())
			sb.append("   <- " + it.next() + "\n");

		return sb.toString();
	}

	public void setCollection(NR_ConceptCollection c) { _collection = c; }

	public NR_ConceptCollection getCollection() { return _collection; }

	public Iterator<String> getKeywords() { return _keywords.iterator(); }

	public void setKeywords(List<String> l) { _keywords = l; }

   public void setKey(Long k) { _key = k; }

   public Long getKey() { return _key; }

	public String getName() { return _name; }

	public String getDefn() { return _defnString; }

	public void setLexerToken(ConceptToken tok) { _lexerToken = tok; }

	public ConceptToken getLexerToken() { return _lexerToken; }

}
