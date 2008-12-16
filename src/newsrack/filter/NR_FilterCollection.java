package newsrack.filter;

import java.util.Collection;
import java.util.Map;
import java.util.HashMap;

import newsrack.filter.Filter;
import newsrack.user.User;

public final class NR_FilterCollection extends NR_Collection
{
	private transient Map<String, Filter> _map = null;  // Name --> Filter mapping .. optimization!
	private transient boolean             _allMapped = false;

	public NR_FilterCollection(User u, String name, Collection entries)
	{
		super(NR_CollectionType.FILTER, u, name, entries);
	}

	public Filter getFilter(String f)
	{
		if (_map == null)
			_map = new HashMap<String, Filter>();

		Object rv = _map.get(f);
		if (rv != null) {
			return (Filter)rv;
		}
		else if (_entries == null) {
				// Not in memory.  Fetch from the db!
			Filter filt = _db.getFilterFromCollection(getKey(), f);
			if (filt != null)
				_map.put(filt.getName(), filt);
			return filt;
		}
		else if (!_allMapped) {
			for (Filter filt: (Collection<Filter>)_entries) {
				_map.put(filt.getName(), filt);
				if (filt.getName().equals(f))
					return filt;
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

	public Collection getFilters()
	{
		if (_entries == null) 
			_entries = _db.getAllFiltersFromCollection(getKey());

		return _entries;
	}

	public Object getEntryByName(String name) { return getFilter(name); }

	public Collection getEntries() { return getFilters(); }
}
