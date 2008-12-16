package newsrack.filter;

import java.lang.Comparable;
import java.util.List;

public final class Count implements Comparable, java.io.Serializable
{
	private int _cnt;
	private List<Integer>  _matchPosns;
	private List<Category> _matchedCats;

	public Count(int n, List<Category> l) 
	{ 
		_cnt = n; 
		_matchedCats = l;
	}

	public Count(int n, int posn)
	{ 
		_cnt = n;
		_matchedCats = null;
		_matchPosns = new java.util.ArrayList<Integer>();
		_matchPosns.add(posn);
	}

	public void addMatch(int posn) { _cnt++; _matchPosns.add(posn); }

	public int value() { return _cnt; }

	public List<Integer> matchPosns() { return _matchPosns; }

	public int compareTo(Object o) { return ((Count)o)._cnt - _cnt; /* desc order */ }

	public List<Category> getMatchedCats() { return _matchedCats; }

	public String toString() { return Integer.toString(_cnt); }
}

