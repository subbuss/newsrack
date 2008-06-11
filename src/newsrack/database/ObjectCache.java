package newsrack.database;

import newsrack.GlobalConstants;
import newsrack.user.User;
import newsrack.archiver.Feed;
import newsrack.archiver.Source;
import newsrack.filter.Category;
import newsrack.filter.Concept;
import newsrack.filter.Filter;
import newsrack.filter.Issue;

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
	private Map<Class, OCache> _caches;

	private class OCache
	{
		private String _name;
		private GeneralCacheAdministrator _osCacheAdmin;

		OCache(String name, Properties p) 
		{ 
			_name = name; 
			_osCacheAdmin = new GeneralCacheAdministrator(p);
		}

		synchronized void add(String[] groups, String key, Object o)
		{
			if (_log.isDebugEnabled()) _log.debug(_name + " CACHE: adding key " + key);
			if (groups == null)
				_osCacheAdmin.putInCache(key, o);
			else
				_osCacheAdmin.putInCache(key, o, groups);
		}

		void remove(String key)
		{
			_osCacheAdmin.removeEntry(key);
		}

		void removeGroup(String group)
		{
			_osCacheAdmin.flushGroup(group);
		}

		void removeGroups(String[] groups)
		{
			for (String g: groups)
				_osCacheAdmin.flushGroup(g);
		}

		Object get(String key)
		{
				// @FIXME  Test efficiency
				// We won't try to update the cache if we don't find an entry
				// BUT, won't this lead to wasteful exceptions?
			try {
				return _osCacheAdmin.getFromCache(key);
			}
			catch (NeedsRefreshException nre) {
         	_osCacheAdmin.cancelUpdate(key);
				return null;
			}
		}

		void printStats()
		{
			if (!_log.isInfoEnabled())
				return;

			_log.info("#### CACHE STATS for " + _name + " ####");
			Object[] elList = _osCacheAdmin.getCache().getCacheEventListenerList().getListenerList();
			for (int i = 0; i < elList.length; i++) {
				Object el = elList[i];
				if (el instanceof CacheEntryEventListenerImpl) {
					_log.info("Cache Entry Event Listener Stats: " + el.toString());
				}
				else if (el instanceof CacheMapAccessEventListenerImpl) {
					_log.info("Cache Map Access Event Listener Stats: " + el.toString());
				}
				else {
					_log.debug("OTHER stats: " + el.toString());
				}
			}
		}
	}

	private OCache _objectCache;
	private OCache _feedCache;
	private OCache _newsItemCache;
	private OCache _userCache;
	private OCache _issueCache;
	private OCache _srcCache;
	private OCache _categoryCache;
	private OCache _filterCache;

	public ObjectCache()
	{
		Properties p = new Properties();
		p.setProperty("cache.memory", "true");
		// Turn off disk persistence
		// p.setProperty("cache.persistence.class", "com.opensymphony.oscache.plugins.diskpersistence.HashDiskPersistenceListener");
		p.setProperty("cache.event.listeners", "com.opensymphony.oscache.extra.CacheEntryEventListenerImpl, com.opensymphony.oscache.extra.CacheMapAccessEventListenerImpl");
		p.setProperty("cache.path", GlobalConstants.getProperty("cache.path"));

		p.setProperty("cache.capacity", "10000");
		_objectCache   = new OCache("OBJECT", p);
		p.setProperty("cache.capacity", "1000");
		_userCache     = new OCache("USER", p);
		p.setProperty("cache.capacity", "500");
		_issueCache    = new OCache("ISSUE", p);
		p.setProperty("cache.capacity", "10000");
		_feedCache     = new OCache("FEED", p);	   /* about 4000 feed objects can fit in 1MB; 256 bytes per feed object in common case */
		p.setProperty("cache.capacity", "20000");
		_srcCache      = new OCache("SOURCE", p);		/* about 8000 source objects can fit in 1MB; 128 bytes per source object in common case */
		p.setProperty("cache.capacity", "10000");
		_categoryCache = new OCache("CATEGORY", p);
		p.setProperty("cache.capacity", "10000");
		_filterCache   = new OCache("FILTER", p);
		p.setProperty("cache.capacity", "10000");		/* about 1000 feed objects should comfortably fit in 1 MB */
		_newsItemCache = new OCache("NEWSITEM", p);

		_caches = new java.util.HashMap<Class, OCache>(10);

		_caches.put(Object.class, _objectCache);
		_caches.put(Feed.class, _feedCache);
		_caches.put(NewsItem.class, _newsItemCache);
		_caches.put(User.class, _userCache);
		_caches.put(Issue.class, _issueCache);
		_caches.put(Source.class, _srcCache);
		_caches.put(Category.class, _categoryCache);
		_caches.put(Filter.class, _filterCache);
	}

	public void printStats()
	{
		for (OCache c: _caches.values())
			c.printStats();
/**
		_objectCache.printStats();
		_feedCache.printStats();
		_newsItemCache.printStats();
		_userCache.printStats();
		_issueCache.printStats();
		_srcCache.printStats();
		_categoryCache.printStats();
		_filterCache.printStats();
**/
	}

	public void add(String[] cacheGroups, Object key, Class c, Object o)
	{
		String nKey;
		OCache cache = _caches.get(c);

		if (cache == null) {
			nKey = Integer.toString(c.hashCode()) + ":" + key.toString();
			cache = _objectCache;
		}
		else {
			nKey = key.toString();
		}

		//_log.info("Adding " + o.hashCode() + " to cache " + cache.hashCode() + " for class " + c + " for key " + nKey);

		cache.add(cacheGroups, nKey, o);
	}

	public void add(Long userKey, Object key, Class c, Object o)
	{
		String[] cacheGroups = null;
		if (userKey != null)
			cacheGroups = new String[]{userKey.toString()};

		add(cacheGroups, key, c, o);
	}

/**
 * Problem with these is when different object types are added / queried 
 * for the same abstract class.  Ex: SQL_IssueStub vs. Issue; ArrayList vs. LinkedList
 *
	public void add(Long userKey, Object key, Object o)
	{
		add(userKey, key, o.getClass(), o);
	}

	public void add(String[] cacheGroups, Object key, Object o)
	{
		add(cacheGroups, key, o.getClass(), o);
	}
**/

	public Object get(Object key, Class c)
	{
		String nKey;
		OCache cache = _caches.get(c);

		if (cache == null) {
			nKey = Integer.toString(c.hashCode()) + ":" + key.toString();
			cache = _objectCache;
		}
		else {
			nKey = key.toString();
		}

		Object o = cache.get(nKey);

		//_log.info("Fetching " + ((o != null) ? o.hashCode() : "null") + " from cache " + cache.hashCode() + " for class " + c + " and key " + nKey);

		return cache.get(nKey);
	}

	public void remove(Object key, Class c)
	{
		String nKey;
		OCache cache = _caches.get(c);

		if (cache == null) {
			nKey = Integer.toString(c.hashCode()) + ":" + key.toString();
			cache = _objectCache;
		}
		else {
			nKey = key.toString();
		}

		cache.remove(nKey);
	}

	public void removeEntriesForGroups(String[] cacheGroups)
	{
		for (OCache c: _caches.values())
			c.removeGroups(cacheGroups);
/**
		_userCache.removeGroups(cacheGroups);
		_feedCache.removeGroups(cacheGroups);
		_newsItemCache.removeGroups(cacheGroups);
		_srcCache.removeGroups(cacheGroups);
		_issueCache.removeGroups(cacheGroups);
		_categoryCache.removeGroups(cacheGroups);
		_filterCache.removeGroups(cacheGroups);
		_objectCache.removeGroups(cacheGroups);
**/
	}

	public void purgeCacheEntriesForUser(User u)
	{
		removeEntriesForGroups(new String[]{u.getUid(), u.getKey().toString()});
	}
}
