package newsrack.database;

import java.lang.ref.WeakReference;
import java.util.Map;

public class StringCache 
{
		// Memory saving device -- record unique strings rather than
		// use duplicate strings for the same value!
	private static Map _stringMap = new java.util.WeakHashMap();

		// Try to retain unique string objects for strings that are identical
		// Reduces memory usage!
	private static int _numStrings    = 0;
	private static int _numStringReqs = 0;

	public static String GetUniqueString(String s)
	{
		_numStringReqs++;

		String        us = null;
		WeakReference o  = (WeakReference)_stringMap.get(s);
		Object        os = (o == null) ? null : o.get();
		if (os != null) {
			us = (String)os;
		}
		else {
				// Without the weak reference, 's' will continue to have
				// a strong reference from within the WeakHashMap!
			_stringMap.put(s, new WeakReference(s));
			us = s;
			_numStrings++;
		}

		return us;
	}

	public static void PrintStats()
	{
		System.out.println("### Number of string requests   - " + _numStringReqs);
		System.out.println("### Number of unique strings    - " + _numStrings);
		System.out.println("### Size of weak hashmap        - " + _stringMap.size());
	}
}
