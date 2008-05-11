package newsrack.filter;

/**
 * DO NOT change the name strings OR the order of the
 * enumeration elements!  These values are stored in
 * the database, and if the names or the order is changed,
 * the collection types stored in the database will be lost!
 */
public enum NR_CollectionType
{
	SOURCE("SRC"),
	CONCEPT("CPT"),
	CATEGORY("CAT"),
	FILTER("FIL");

	static public NR_CollectionType getType(String typeStr)
	{
		if (typeStr.equals("SRC")) return SOURCE;
		else if (typeStr.equals("CPT")) return CONCEPT;
		else if (typeStr.equals("CAT")) return CATEGORY;
		else if (typeStr.equals("FIL")) return FILTER;
		else return null;
	}
	
	public final String _typeStr;

	NR_CollectionType(String typeStr) { _typeStr = typeStr; }

	public String toString() { return _typeStr; }
}
