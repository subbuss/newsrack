package newsrack.filter;

import java.util.List;
import newsrack.GlobalConstants;
import newsrack.database.DB_Interface;
import newsrack.user.User;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public abstract class NR_Collection
{
// ############### STATIC FIELDS AND METHODS ############
   protected static Log _log = LogFactory.getLog(NR_Collection.class);

	protected static DB_Interface _db;

	public static void init(DB_Interface db) { _db = db; }

	public static NR_Collection getCollection(NR_CollectionType type, String uid, String name)
	{
		return _db.getCollection(type, uid, name);
	}

	public static void recordImportDependency(String fromUid, String toUid)
	{
		_db.recordImportDependency(fromUid, toUid);
	}

// ############### NON-STATIC FIELDS AND METHODS ############
	      public Long   _key;
	final public User   _creator;
	final public String _name;
	final public NR_CollectionType _type;
	      public List   _entries;

	public NR_Collection(NR_CollectionType t, User u, String name, List entries)
	{
		_type    = t;
		_creator = u;
		_name    = name;
		_entries = entries;
	}

	public void setKey(Long k) { _key = k; } 

	public Long getKey() { return _key; } 

	public String getName() { return _name; } 

	public NR_CollectionType getType() { return _type; }

	public User getCreator() { return _creator; }

	public abstract List getEntries();
}
