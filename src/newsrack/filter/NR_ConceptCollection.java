package newsrack.filter;

import java.util.List;
import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;

import newsrack.filter.Concept;
import newsrack.user.User;

public final class NR_ConceptCollection extends NR_Collection
{
	private transient Map<String, Concept> _map = null;  // Name --> Concept mapping .. optimization!
	private transient boolean              _allMapped = false;

	public NR_ConceptCollection(User u, String name, List entries)
	{
		super(NR_CollectionType.CONCEPT, u, name, entries);
      if (_log.isDebugEnabled()) _log.debug("RECORDED concept collection with name " + name + " for user " + u.getUid());
	}

	public Concept getConcept(String c)
	{
		if (_map == null)
			_map = new HashMap<String, Concept>();

		Object rv = _map.get(c);
		if (rv != null) {
			return (Concept)rv;
		}
		else if (_entries == null) {
				// Not in memory.  Fetch from the db!
			Concept cpt = _db.getConceptFromCollection(getKey(), c);
			if (cpt != null)
				_map.put(cpt.getName(), cpt);
			return cpt;
		}
		else if (!_allMapped) {
			for (Concept cpt: (List<Concept>)_entries) {
				_map.put(cpt.getName(), cpt);
				if (cpt.getName().equals(c))
					return cpt;
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

	public List getEntries() { return getConcepts(); }

	public List getConcepts()
	{
		if (_entries == null) 
			_entries = _db.getAllConceptsFromCollection(getKey());

		return _entries;
	}
}
