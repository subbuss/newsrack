package newsrack.database;

import newsrack.NewsRack;
import newsrack.user.User;
import newsrack.archiver.Feed;
import newsrack.archiver.Source;
import newsrack.filter.Category;
import newsrack.filter.Concept;
import newsrack.filter.Filter;
import newsrack.filter.Issue;
import newsrack.util.Tuple;

import java.io.PrintWriter;
import java.util.Properties;
import java.util.Map;

import com.opensymphony.oscache.base.*;
import com.opensymphony.oscache.extra.*;
import com.opensymphony.oscache.general.*;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class ObjectCache
{
   private static Log _log = LogFactory.getLog(ObjectCache.class);

	private class OCache
	{
		private String _name;
		private GeneralCacheAdministrator _osCacheAdmin;

		OCache(String name, Properties p) 
		{ 
			_name = name; 
			_osCacheAdmin = new GeneralCacheAdministrator(p);
		}

		void add(String[] groups, String key, Object o)
		{
			if (_log.isDebugEnabled()) _log.debug(_name + " CACHE: adding key " + key);
			// FIXME: Do I need a "synchronized (key.intern())" here?
			if (groups == null)
				_osCacheAdmin.putInCache(key, o);
			else
				_osCacheAdmin.putInCache(key, o, groups);
		}

		void remove(String key) { _osCacheAdmin.removeEntry(key); }

		void removeGroup(String group) { _osCacheAdmin.flushGroup(group); }

		void removeGroups(String[] groups)
		{
			for (String g: groups)
				_osCacheAdmin.flushGroup(g);
		}

		void clear() { _osCacheAdmin.flushAll(); }

      void destroy() { _osCacheAdmin.destroy(); }

		Object get(String key)
		{
				// We won't try to update the cache if we don't find an entry
			try {
				return _osCacheAdmin.getFromCache(key);
			}
			catch (NeedsRefreshException nre) {
         	_osCacheAdmin.cancelUpdate(key);
				return null;
			}
		}

		void printStats(StringBuffer sb)
		{
			sb.append("#### CACHE STATS for " + _name + " ####").append("\n");
			Object[] elList = _osCacheAdmin.getCache().getCacheEventListenerList().getListenerList();
			for (int i = 0; i < elList.length; i++) {
				Object el = elList[i];
				if (el instanceof CacheEntryEventListenerImpl) {
					sb.append("Cache Entry Event Listener Stats: ").append(el.toString()).append("\n");
				}
				else if (el instanceof CacheMapAccessEventListenerImpl) {
					sb.append("Cache Map Access Event Listener Stats: ").append(el.toString()).append("\n");
				}
				else {
					sb.append("OTHER stats: " + el.toString()).append("\n");
				}
			}
		}
	}

	private Map<String, OCache> _caches;	// Item-specific caches
	private OCache _objectCache;			// Special catch-all cache

	private OCache buildCache(String name, Properties p)
	{
		p.setProperty("cache.capacity", NewsRack.getProperty(name + ".cache.size"));
		OCache c = new OCache(name.toUpperCase(), p);
		_caches.put(name.toUpperCase(), c);
		return c;
	}

	private void buildAllCaches()
	{
		_caches = new java.util.HashMap<String, OCache>(10);

		Properties p = new Properties();

		// No disk persistence!
		// p.setProperty("cache.persistence.class", "com.opensymphony.oscache.plugins.diskpersistence.HashDiskPersistenceListener");
		// p.setProperty("cache.path", NewsRack.getProperty("cache.path"));

		p.setProperty("cache.memory", "true");
		p.setProperty("cache.event.listeners", "com.opensymphony.oscache.extra.CacheEntryEventListenerImpl, com.opensymphony.oscache.extra.CacheMapAccessEventListenerImpl");

		buildCache("user", p);
		buildCache("issue", p);
		buildCache("feed", p);
		buildCache("source", p);
		buildCache("category", p);
		buildCache("filter", p);
		buildCache("newsitem", p);

			// Lastly, a generic object cache
		_objectCache  = buildCache("object", p); 	// 10000
	}

	private Tuple<OCache, String> getCacheAndKey(String cacheName, Object key)
	{
		String nKey;
		OCache cache = _caches.get(cacheName);

		if (cache == null) {
			nKey = cacheName + ":" + key.toString();
			cache = _objectCache;
		}
		else {
			nKey = key.toString();
		}

		return new Tuple<OCache, String>(cache, nKey);
	}

	public ObjectCache()
	{
		buildAllCaches();
	}

	public void printStats(StringBuffer sb)
	{
		for (OCache c: _caches.values())
			c.printStats(sb);
	}

	public void add(String cacheName, String[] cacheGroups, Object key, Object o)
	{
		Tuple<OCache, String> t = getCacheAndKey(cacheName, key);
		t._a.add(cacheGroups, t._b, o);
	}

	public void add(String cacheName, Long userKey, Object key, Object o)
	{
		String[] cacheGroups = null;
		if (userKey != null)
			cacheGroups = new String[]{userKey.toString()};

		add(cacheName, cacheGroups, key, o);
	}

	public void add(String cacheName, Object key, Object o)
	{
		add(cacheName, (String[])null, key, o);
	}

	public Object get(String cacheName, Object key)
	{
		Tuple<OCache, String> t = getCacheAndKey(cacheName, key);
		return t._a.get(t._b);
	}

	public void remove(String cacheName, Object key)
	{
		Tuple<OCache, String> t = getCacheAndKey(cacheName, key);
		t._a.remove(t._b);
	}

	public void removeEntriesForGroups(String[] cacheGroups)
	{
		for (OCache c: _caches.values())
			c.removeGroups(cacheGroups);
	}

	public void purgeCacheEntriesForUser(User u)
	{
		removeEntriesForGroups(new String[]{u.getUid(), u.getKey().toString()});
	}

	public void clearCaches()
	{
		Map<String, OCache> oldCaches = _caches;

			// Build all caches from scratch!
		buildAllCaches();

			// Destroy all the old caches
		for (OCache c: oldCaches.values())
			c.destroy();
	}
}
