package newsrack.filter;

import newsrack.database.DB_Interface;
import newsrack.user.User;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.Collection;

public abstract class NR_Collection implements java.io.Serializable {
    // ############### STATIC FIELDS AND METHODS ############
    protected static Log _log = LogFactory.getLog(NR_Collection.class);

    protected static DB_Interface _db;
    final public User _creator;
    final public UserFile _file;
    final public String _name;
    final public NR_CollectionType _type;
    // ############### NON-STATIC FIELDS AND METHODS ############
    public Long _key;
    public Collection _entries;
    private int _hashCode;
    public NR_Collection(NR_CollectionType t, UserFile uf, String name, Collection entries) {
        _type = t;
        _file = uf;
        _creator = uf.getUser();
        _name = name;
        _entries = entries;
        _hashCode = _name.hashCode() * 31 + _type.hashCode() * 31 + _creator.hashCode() * 31;
        if (_log.isDebugEnabled()) _log.debug("RECORDED collection " + this);
    }

    public static void init(DB_Interface db) {
        _db = db;
    }

    public static NR_Collection getCollection(NR_CollectionType type, String uid, String name) {
        return _db.getCollection(type, uid, name);
    }

    public static void recordImportDependency(String fromUid, String toUid) {
        _db.recordImportDependency(fromUid, toUid);
    }

    public boolean equals(Object o) {
        if ((o != null) && (o instanceof NR_Collection)) {
            NR_Collection c = (NR_Collection) o;
            return _name.equals(c._name) && _type.equals(c._type) && _creator.equals(c._creator);
        }
        return false;
    }

    public int hashCode() {
        return _hashCode;
    }

    public String toString() {
        return "NAME: " + _name + "; type - " + _type + "; creator - " + _creator.getUid();
    }

    public Long getKey() {
        return _key;
    }

    public void setKey(Long k) {
        _key = k;
    }

    public String getName() {
        return _name;
    }

    public NR_CollectionType getType() {
        return _type;
    }

    public UserFile getFile() {
        return _file;
    }

    public User getCreator() {
        return _creator;
    }

    public void mergeCollection(NR_Collection c) {
        getEntries().addAll(c.getEntries());
    }

    public abstract Object getEntryByName(String name);

    public abstract Collection getEntries();
}
