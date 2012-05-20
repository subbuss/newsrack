package newsrack.filter;

import java.io.PrintWriter;
import java.io.PushbackReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import newsrack.util.Tuple;

public class ConceptTrie {
   static public class Node {
		Character                _c;
		String                   _matchedString;
      HashMap<Character, Node> _children;
      List<Concept>            _matchedConcepts;

      // SSS FIXME: Should we use sensible defaults for initial capacity and load factor for _children?
      Node(Character c, String s) { 
			_c               = c;
			_matchedString   = s;
			_children        = new HashMap<Character, Node>(); 
			_matchedConcepts = null;
		}
   }

   Node _root;

   public ConceptTrie() {
      _root = new Node('_', ""); // arbitrary character for the root
   }

   public void addKeyword(String str, Concept cpt) {
      char[] chars  = str.toCharArray();
      int    strLen = chars.length;
      Node   n      = _root;

      // Walk down the trie, creating new nodes as needed
      for (int i = 0; i < strLen; i++) {
			// Normalize trie chars to lower case
         Character c = new Character(Character.toLowerCase(chars[i]));
         Node child = n._children.get(c);
         if (child == null) {
            child = new Node(c, str.substring(0, i+1));
            n._children.put(c, child);
         }
         n = child;
      }

      // Record concept
		if (n._matchedConcepts == null) n._matchedConcepts = new ArrayList<Concept>();
      n._matchedConcepts.add(cpt);
   }

	// Start matching str in the given state and return the ending state
   public Node matchString(Object startState, String str) {
      char[] chars  = str.toCharArray();
      int    strLen = chars.length;
      Node   n      = startState == null ? _root : (Node)startState;

      // Walk down the trie
      for (int i = 0; i < strLen; i++) {
         char c = chars[i];
         Node child = n._children.get(c);
         if (child == null) return null;
         n = child;
      }

      return n;
   }

	private void processMatchedConcepts(List<Concept> matchedConcepts, String matchedText, int tokenPosn, Map<Concept, Score> tokTable, PrintWriter pw) {
		// Increment match score of the matched concept and record information
		// about where in the article it was found
		for (Concept c: matchedConcepts) {
			Score cnt = (Score)tokTable.get(c);
			if (cnt == null) {
				tokTable.put(c, new Score(tokenPosn));
			} else {
				cnt.addMatch(tokenPosn);
			}

				// Output the concept to the token file for debugging purposes
			if (pw != null) {
				pw.println(c.getName() + "<" + c.getKey() + ">:" + tokenPosn + ":TEXT=" + matchedText);
			}
			System.out.println(c.getName() + "<" + c.getKey() + ">:" + tokenPosn + ":TEXT=" + matchedText);
		}
	}

	private boolean skipHeader(PushbackReader pbr) throws java.io.IOException {
		char[] signals  = "<pre>".toCharArray();
		char   trigger  = signals[0];
		int    endState = signals.length;
		int    state    = 0;

		while (true) {
			int i = pbr.read();
			if (i == -1) return true;

			char c = (char)i;
			if (state > 0) {
				state = (c == signals[state]) ? state + 1 : 0;
				// Done with header.  We are ready to process text
				if (state == endState) return false;
			} else if (c == trigger) {
				state = 1;
			}
		}
	}

	private char swallowWhiteSpace(char c, PushbackReader pbr) throws java.io.IOException {
		// Hmm .. I need a separate check for '\n'.  
		// Surprised it is not considered a space-character
		char separator = c;

		// Swallow white-space and hyphens
		while (true) {
			int i = pbr.read();
			if (i == -1) {
				break;
			} else {
				c = (char)i;
				if (c == '-') {
					separator = '-';
				} else if (c != '\n' && !Character.isSpaceChar(c)) {
					pbr.unread(i);
					break;
				} 
			}
		}

		// Normalize all white-space sequences to a single space
		if (separator == '\n' || Character.isSpaceChar(separator)) separator = ' ';

		return separator;
	}

	// Find all concepts that match 
	public Tuple<Integer, Map<Concept, Score>> processArticle(Reader r, PrintWriter pw) throws java.io.IOException {
		String    currToken  = null;
		ArrayList prevStates = new ArrayList();
		int       tokenPosn  = 0;

		StringBuffer        buf      = new StringBuffer();
		Map<Concept, Score> tokenMap = new HashMap<Concept, Score>();

		// Use a 1-character buffer pushback reader
		PushbackReader pbr = new PushbackReader(r);

		try {
			boolean eof = skipHeader(pbr);
			while (!eof) {
				ArrayList newStates = new ArrayList();
				char      separator = ' ';

				// Read stream and build up a token
				boolean done = false;
				while (!done) {
					int i = pbr.read();
					if (i == -1) {
						done = true;
						eof = true;
					} else {
						char c = (char)i;
						if (Character.isLetterOrDigit(c) || Character.isHighSurrogate(c) || Character.isLowSurrogate(c)) {
							buf.append(c);
						} else {
							// FIXME: Normalize white-space
							separator = swallowWhiteSpace(c, pbr);
							done = true;
						}
					}
				}
				String token = buf.toString();
				tokenPosn++;

				// Clear buffer
				buf.delete(0, buf.length());

				// Match token from the root
				//System.out.println(tokenPosn + ". TOKEN: " + token + "; separator: <" + separator + ">");
				Node match = matchString(null, token);
				if (match != null) {
					if (match._matchedConcepts != null) processMatchedConcepts(match._matchedConcepts, match._matchedString, tokenPosn, tokenMap, pw);
					if (!eof) {
						// Match the separator
						match = match._children.get(separator);
						if (match != null) newStates.add(match);
					}
				}

				// Match from each of the match states from previous tokens
				for (Object s: prevStates) {
					match = matchString(s, token);
					if (match != null) {
						// fixme
						if (match._matchedConcepts != null) processMatchedConcepts(match._matchedConcepts, match._matchedString, tokenPosn, tokenMap, pw);
						if (!eof) {
							// Match the separator
							match = match._children.get(separator);
							if (match != null) newStates.add(match);
						}
					}
				}

				// new previous states
				prevStates = newStates;
			}
		} finally {
			pbr.close();
		}

		return new Tuple<Integer, Map<Concept,Score>>(tokenPosn, tokenMap);
	}
}
