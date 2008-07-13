package newsrack.database.sql;

import newsrack.database.NewsItem;
import newsrack.filter.Issue;
import newsrack.filter.Category;
import newsrack.user.User;
import newsrack.archiver.Source;
import newsrack.archiver.Feed;

import java.util.List;
import java.util.Hashtable;
import java.util.Collection;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Date;

// @FIXME: record info. about materialized fields and don't hit the db if it is already in memory
class SQL_IssueStub extends Issue
{
	Long    _userKey;
	boolean _loaded;

	public SQL_IssueStub(Long key, Long userKey, String name, int numArts, Date lut, boolean isValidated, boolean isFrozen, boolean isPrivate, String taxoPath, int numNew)
	{
		super(name, isValidated, isFrozen, isPrivate);

		_userKey = userKey;
		super.setKey(key);
		super.setNumArticles(numArts);
		super.setLastUpdateTime(lut);
		super.setTaxonomyPath(taxoPath);
		super.setNumItemsSinceLastDownload(numNew);
		_loaded = false;
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

	public Category getCategory(int catId)
	{
		if (_loaded) {
			return super.getCategory(catId);
		}
		else {
				// load categories first!
			getCategories();
			return super.getCategory(catId);
		}
	}

	public Collection<Category> getCategories()
	{
		Collection<Category> topLevelCats;
		if (_loaded) {
			topLevelCats = super.getCategories();
		}
		else {
			getUser(); // Load the user field too!
			topLevelCats = new ArrayList<Category>();
			List<Category> cats = (List<Category>)SQL_Stmt.GET_CATS_FOR_ISSUE.execute(new Object[] { getKey() });
			for (Category c: cats) {
				c.setIssue(this);
				if (c.isTopLevelCategory())
					topLevelCats.add(c);
			}
			_loaded = true;	// Set this flag before adding categories to avoid infinite loops!
			super.addCategories(topLevelCats);
		}
		return topLevelCats;
	}

	public Collection<Source> getMonitoredSources()
	{
		Collection<Source> srcs = super.getMonitoredSources();
		if (srcs == null) {
			srcs = (List<Source>)SQL_Stmt.GET_MONITORED_SOURCES_FOR_TOPIC.execute(new Object[] { getKey() });
			super.addSources(srcs);
		}
		return srcs;
	}

	public void reclassifyNews(Source s, boolean allDates, Date sd, Date ed)
	{
		getUser();
		super.reclassifyNews(s, allDates, sd, ed);
	}

	public void scanAndClassifyNewsItems(Feed f, Collection<NewsItem> news)
	{
		getUser();
		super.scanAndClassifyNewsItems(f, news);
	}

	public void gen_JFLEX_RegExps()
	{
		getUser();
		super.gen_JFLEX_RegExps();
	}
}
