package newsrack.filter;

import java.io.*;
import java.util.*;

/**
 * May 31, 2004
 */


public class Histogram
{
	private static class Item implements Comparable 
	{
		public String _w;
		public int    _cnt;

		public Item(String s, int n) { _w = s; _cnt = n; }
		public void Increment()      { _cnt++; }

		public int compareTo(Object o)
		{
			return ((Item)o)._cnt - _cnt; // descending order
		}

		public String toString()
		{
			return _w + "\t\t\t: " + _cnt;
		}
	}

	public final static Hashtable SKIP_TABLE;

	public final static String[] SKIP_WORDS = {
			"___BEGIN___",
			"a", "an", "the",
			"it", "this", "that",
			"he", "she", "his", "her", "him",
			"i", "am", "me", "my", "we", "us", "our",
			"you", "your", "they", "them", "their",
			"as", "of", "in", "on", "to", "by", "at",
			"for", "from", "with", "than",
			"too", "also", "very", "only",
			"be", "been", "is", "are", "was", "were",
			"should", "could", "would", "must",
			"so", "therefore", "moreover", "however", "but", "because", "since",
			"has", "had", "have",
			"why", "what", "when", "where", "which", "who", "how", 
			"and", "or", "not", "yes", "no", "if", "else", "then",
			"do", "did", "does", "done",
			"here", "there", "come", "go", "about", "around",
			"any", "yet",
			"said",
			"___END___"
	};
/*
 NOT INCLUDING the following because they have other meanigns:
     will, may, might, can
 */

	static {
		SKIP_TABLE = new Hashtable();

		int n = SKIP_WORDS.length;
		for (int i = 0; i < n; i++) {
			String s = SKIP_WORDS[i];
			SKIP_TABLE.put(s, s);
		}
	}

	public final static void main(String[] args)
	{
		try {
			String          fname = args[0];
			FileInputStream fis   = new FileInputStream(new File(fname));
			BufferedReader  br    = new BufferedReader(new InputStreamReader(fis));
			StreamTokenizer st    = new StreamTokenizer(br);

				// Set up the stream tokenizer state
			st.wordChars('a', 'z');
			st.wordChars('A', 'Z');
			st.wordChars('0', '9');
			st.wordChars('_', '_');
			st.wordChars('\'', '\'');
			st.ordinaryChars('.', '.');
			st.ordinaryChars(',', ',');
			st.ordinaryChars(';', ';');
			st.ordinaryChars(':', ':');
			st.ordinaryChars('-', '-');
			st.whitespaceChars(' ', ' ');
			st.whitespaceChars('\t', '\t');
			st.whitespaceChars('\n', '\n');
			st.whitespaceChars('\r', '\r');
			st.whitespaceChars('\f', '\f');
			st.eolIsSignificant(false);
			st.lowerCaseMode(true);

				// Now parse tokens
			Hashtable hist            = new Hashtable();
			int       numTokens       = 0;
			int       numWords        = 0;
			int       numSkippedWords = 0;
			int       tokenType;
			while ((tokenType = st.nextToken()) != StreamTokenizer.TT_EOF) {
				numTokens++;
				if (tokenType == StreamTokenizer.TT_WORD) {
					System.out.println("TOKEN: " + st.sval);
					String w = st.sval;
					if (SKIP_TABLE.get(w) == null) {
						Item itm = (Item)hist.get(w);
						if (itm == null)
							hist.put(w, new Item(w, 1));
						else
							itm.Increment();

						numWords++;
					}
					else {
						numSkippedWords++;
					}
				}
			}

			System.out.println("SEEN " + numTokens + " tokens");
			System.out.println("Added " + numWords + " in the histogram.");
			System.out.println("Skipped " + numSkippedWords + " from the stram.");

			LinkedList  l = new LinkedList();
			Enumeration e = hist.elements();
			while (e.hasMoreElements())
				l.add(e.nextElement());

			Collections.sort(l);
			Iterator it = l.iterator();
			while (it.hasNext())
				System.out.println(it.next().toString());
		}
		catch (java.io.IOException e) {
			System.err.println("Exception : " + e);
		}
	}
}
