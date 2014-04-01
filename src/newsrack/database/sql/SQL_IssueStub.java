package newsrack.database.sql;

import newsrack.archiver.Feed;
import newsrack.archiver.Source;
import newsrack.database.NewsItem;
import newsrack.filter.Category;
import newsrack.filter.Issue;
import newsrack.user.User;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;

// @FIXME: record info. about materialized fields and don't hit the db if it is already in memory
class SQL_IssueStub extends Issue {
    Long _userKey;
    boolean _loaded;

    public SQL_IssueStub(Long key, Long userKey, String name, int numArts, Date lut, boolean isValidated, boolean isFrozen, boolean isPrivate, String taxoPath, int numNew) {
        super(name, isValidated, isFrozen, isPrivate);

        _userKey = userKey;
        super.setKey(key);
        super.setNumArticles(numArts);
        super.setLastUpdateTime(lut);
        super.setTaxonomyPath(taxoPath);
        super.setNumItemsSinceLastDownload(numNew);
        _loaded = false;
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

    public Category getCategory(int catId) {
        if (_loaded) {
            return super.getCategory(catId);
        } else {
            // load categories first!
            getCategories();
            return super.getCategory(catId);
        }
    }

    public Collection<Category> getCategories() {
        if (_loaded)
            return super.getCategories();

        // NOTE: It is okay to synchronize on 'this' because it will come from a cache -- and is hence
        // shared across all threads
        synchronized (this) {
            // Need this second check because of potential race condition around the if (_loaded) check
            // outside the synchronized block.  We could avoid this second check by synchronizing
            // all code in this method, but we don't want to do that -- because in the common case,
            // the cats would already have been loaded!
            if (_loaded)
                return super.getCategories();

            getUser(); // Load the user field too!
            Collection<Category> topLevelCats = new ArrayList<Category>();
            // To take advantage of caching (and avoid zillions of identical objects in the cache), fetch category keys and fetch categories by key
            List<Long> catKeys = (List<Long>) SQL_Stmt.GET_CAT_KEYS_FOR_ISSUE.get(getKey());
            for (Long k : catKeys) {
                Category c = SQL_DB._sqldb.getCategory(k);
                c.setIssue(this);
                if (c.isTopLevelCategory())
                    topLevelCats.add(c);
            }
            _loaded = true;    // Since code in addCategories might call getCategories, set this flag before that call to avoid infinite loops
            super.setCategories(topLevelCats);
            return topLevelCats;
        }
    }

    public Collection<Source> getMonitoredSources() {
        Collection<Source> srcs = super.getMonitoredSources();
        if (srcs == null) {
            // NOTE: It is okay to synchronize on 'this' because it will come from a cache -- and is hence
            // shared across all threads
            synchronized (this) {
                // Need this second check because of potential race condition around the check (if srcs == null)
                // outside the synchronized block.  We could avoid this second check by synchronized
                // all code in this method, but we don't want to do that -- because in the common case,
                // the srcs would already have been loaded!
                srcs = super.getMonitoredSources();
                if (srcs == null) {
                    List<Long> keys = (List<Long>) SQL_Stmt.GET_MONITORED_SOURCE_KEYS_FOR_TOPIC.execute(new Object[]{getKey()});
                    srcs = new ArrayList<Source>();
                    for (Long k : keys)
                        srcs.add(SQL_DB._sqldb.getSource(k));

                    // Sort by name
                    java.util.Collections.sort((List) srcs, Source.sourceComparator);
                    super.addSources(srcs);
                }
            }
        }
        return srcs;
    }

    public void reclassifyNews(Source s, boolean allDates, Date sd, Date ed) {
        getUser();
        super.reclassifyNews(s, allDates, sd, ed);
    }

    public void scanAndClassifyNewsItems(Feed f, Collection<NewsItem> news) {
        getUser();
        super.scanAndClassifyNewsItems(f, news);
    }

    public void gen_JFLEX_RegExps() {
        getUser();
        super.gen_JFLEX_RegExps();
    }
}
