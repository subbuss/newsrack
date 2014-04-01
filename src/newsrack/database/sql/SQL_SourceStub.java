package newsrack.database.sql;

import newsrack.archiver.Feed;
import newsrack.archiver.Source;
import newsrack.database.NewsItem;
import newsrack.user.User;

import java.util.Collection;

// @FIXME: record info. about materialized fields and don't hit the db if it is already in memory
class SQL_SourceStub extends Source {
    private Long _feedKey;
    private Long _userKey;
    private boolean _cacheable;
    private boolean _showCacheLinks;

    public SQL_SourceStub(Long srcKey, Long feedKey, Long userKey, String name, String tag, boolean cacheable, boolean showCacheLinks) {
        super(srcKey, name, tag);
        _feedKey = feedKey;
        _userKey = userKey;
        _cacheable = cacheable;
        _showCacheLinks = showCacheLinks;
    }

    public Long getUserKey() {
        return _userKey;
    }

    public User getUser() {
        User u = super.getUser();
        if (u == null) {
            u = SQL_DB._sqldb.getUser(_userKey);
            super.setUser(u);
        }
        return u;
    }

    public Feed getFeed() {
        Feed f = super.getFeed();
        if (f == null) {
            if (_log.isDebugEnabled()) _log.debug("Fetching feed from the db for: " + _feedKey);
            f = SQL_DB._sqldb.getFeed(_feedKey);
            if (f == null)
                _log.error("Got null feed for key: " + _feedKey + " for source: " + getTag());
            super.setFeed(f);
        }
        return f;
    }

    public boolean getCacheableFlag() {
        return _cacheable;
    }

    public boolean getCachedTextDisplayFlag() {
        return _showCacheLinks;
    }

    // Stubs
    public int hashCode() {
        getFeed();
        getUser();
        return super.hashCode();
    }

    public boolean equals(Object o) {
        getFeed();
        getUser();
        return super.equals(o);
    }

    public Collection<NewsItem> read() throws Exception {
        getFeed();
        return super.read();
    }
}
