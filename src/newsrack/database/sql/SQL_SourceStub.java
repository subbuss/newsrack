package newsrack.database.sql;

import newsrack.archiver.Source;
import newsrack.archiver.Feed;
import newsrack.user.User;
import newsrack.database.NewsItem;

import java.util.Date;
import java.util.Collection;
import java.io.OutputStream;

// @FIXME: record info. about materialized fields and don't hit the db if it is already in memory
class SQL_SourceStub extends Source
{
	private Long    _feedKey;
	private Long    _userKey;
	private boolean _cacheable;
	private boolean _showCacheLinks;

	public SQL_SourceStub(Long srcKey, Long feedKey, Long userKey, String name, String tag, boolean cacheable, boolean showCacheLinks)
	{
		super(srcKey, name, tag);
		_feedKey = feedKey;
		_userKey = userKey;
		_cacheable = cacheable;
		_showCacheLinks = showCacheLinks;
	}

	public Long getUserKey() { return _userKey; }

	public User getUser()
	{ 
		User u = super.getUser();
		if (u == null) {
			u = SQL_DB._sqldb.getUser(_userKey); 
			super.setUser(u);
		}
		return u;
	}

	public Feed getFeed()
	{ 
		Feed f = super.getFeed();
		if (f == null) {
			_log.debug("Fetching feed from the db!");
			f = SQL_DB._sqldb.getFeed(_feedKey); 
			super.setFeed(f);
		}
		return f;
	}

	public Collection<NewsItem> readSource() throws Exception
	{
		getFeed();
		return super.readSource();
	}

   public boolean getCacheableFlag()         { return _cacheable; }
   public boolean getCachedTextDisplayFlag() { return _showCacheLinks; }
}
