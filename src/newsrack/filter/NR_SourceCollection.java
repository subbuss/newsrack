package newsrack.filter;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import newsrack.archiver.Source;
import newsrack.user.User;

public final class NR_SourceCollection extends NR_Collection
{
	private transient Map<String, Source> _map = null;  // Name --> Source mapping .. optimization!
	private transient boolean             _allMapped = false;

	public NR_SourceCollection(User u, String name, Collection entries)
	{
		super(NR_CollectionType.SOURCE, u, name, entries);
	}

	public Source getSource(String s)
	{
		if (_map == null)
			_map = new HashMap<String, Source>();

		Object rv = _map.get(s);
		if (rv != null) {
			return (Source)rv;
		}
		else if (_entries == null) {
				// Not in memory.  Fetch from the db!
			Source src = _db.getSourceFromCollection(getKey(), s);
			if (src != null)
				_map.put(src.getTag(), src);
			return src;
		}
		else if (!_allMapped) {
			for (Source src: (Collection<Source>)_entries) {
				_map.put(src.getTag(), src);
				if (src.getTag().equals(s))
					return src;
			}
				// We have mapped all entries in the list
			_allMapped = true;
			return null;
		}
		else {
				// We have an in-memory collection and we have run through 
				// all entries in the list previously and added them to the hashmap!
			return null;
		}
	}

	public Collection getSources()    
	{ 
		if (_entries == null) 
			_entries = _db.getAllSourcesFromCollection(getKey());

		return _entries;
	}

	public Object getEntryByName(String name) { return getSource(name); }

	public Collection getEntries() { return getSources(); }
}
