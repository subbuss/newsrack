package newsrack.filter;

import java.lang.Comparable;
import java.util.List;

public final class Count implements Comparable, java.io.Serializable
{
	private int _cnt;
	private List<Category> _matchedCats;

	public Count(int n, List<Category> l) 
	{ 
		_cnt = n; 
		_matchedCats = l; 
	}

	public Count(int n)
	{ 
		_cnt = n;
		_matchedCats = null;
	}

	public void increment() { _cnt++; }
	 
	public int value() { return _cnt; }

	public int compareTo(Object o) { return ((Count)o)._cnt - _cnt; /* desc order */ }

	public List<Category> getMatchedCats() { return _matchedCats; }

	public String toString() { return Integer.toString(_cnt); }
}

