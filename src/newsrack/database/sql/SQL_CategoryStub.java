package newsrack.database.sql;

import java.util.Set;
import java.util.List;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Date;

import newsrack.user.User;
import newsrack.database.NewsItem;
import newsrack.filter.Issue;
import newsrack.filter.Filter;
import newsrack.filter.Count;
import newsrack.filter.Category;
import newsrack.filter.Concept;

class SQL_CategoryStub extends Category
{
	Long _userKey;		// User who defined this category
	Long _filtKey;		// Filter for this category
	Long _parentCat;	// Category key for the parent
	Long _issueKey;	// Issue key that this cat belongs to

	public SQL_CategoryStub(Long userKey, Long catKey, String name, int catId, Long parentCat, Long filtKey)
	{
		super(catKey, name, null, catId);
		_userKey = userKey;
		_filtKey = filtKey;
		_parentCat = parentCat;
	}

	public User getUser()
	{
		User u = super.getUser();
		if (u == null)
			u = SQL_DB._sqldb.getUser(_userKey); 
		else
			_log.debug("_userKey is " + _userKey);
		return u;
	}

	public Issue getIssue()
	{
		Issue i = super.getIssue();
		if ((i == null) && (_issueKey != null) && (_issueKey != -1))
			i = SQL_DB._sqldb.getIssue(_issueKey);
		else
			_log.debug("_issueKey is " + _issueKey);

		return i;
	}

	public Filter getFilter()
	{
		if (_log.isDebugEnabled()) _log.debug("filter key for " + getName() + " is " + _filtKey);
		if ((_filtKey == null) || (_filtKey == -1)) {
			return null;
		}
		else {
			Filter f = super.getFilter();
			if (f == null) {
				f = SQL_DB._sqldb.getFilter(_filtKey); 
				super.setFilter(f);
			}
			return f;
		}
	}

	public Category getParent()
	{
		if ((_parentCat == null) || (_parentCat == -1)) {
			_log.debug("No parent!");
			return null;
		}
		else {
			Category p = super.getParent();
			if (p == null) {
				_log.debug("Fetching parent from db!");
				p = SQL_DB._sqldb.getCategory(_parentCat);
				super.setParent(p);
			}
			else {
				_log.debug("Returning parent directly!");
			}
			return p;
		}
	}

	public List<Category> getChildren()
	{
		List<Category> ch = super.getChildren();
		if (!isLeafCategory() && ch.isEmpty()) {
/**
			List<Category> children = (List<Category>)SQL_Stmt.GET_NESTED_CATS.execute(new Object[]{getKey()});
			setChildren(children);
			for (Category c: children) {
				c.setParent(this);
				c.setIssue(this.getIssue());
			}
**/
				// To take advantage of caching (and avoid zillions of identical objects in the cache), fetch category keys and fetch categories by key
			List<Category> children = new ArrayList<Category>();
			List<Long> childKeys = (List<Long>)SQL_Stmt.GET_NESTED_CAT_KEYS.get(getKey());
			for (Long k: childKeys) {
				Category c = SQL_DB._sqldb.getCategory(k); 
				c.setParent(this);
				c.setIssue(this.getIssue());
				children.add(c);
			}
			setChildren(children);
			ch = children;
		}
		return ch;
	}

	public boolean isTopLevelCategory() { return (getParent() == null); }
	public boolean isLeafCategory() { return (getFilter() != null); }
	protected void setIssueKey(Long k) { _issueKey = k; }

	private void setupAll() { getFilter(); getParent(); getChildren(); }

	// STUB METHODS BELOW!
	public Category clone() { setupAll(); return super.clone(); }
	protected void setupForDownloading(Issue issue) { setupAll(); super.setupForDownloading(issue); }
	protected void collectUsedConcepts(Set<Concept> usedConcepts) { setupAll(); super.collectUsedConcepts(usedConcepts); }
	public synchronized Count getMatchCount(final NewsItem article, final int numTokens, final Hashtable matchCounts) { setupAll(); return super.getMatchCount(article, numTokens, matchCounts); } 
	// public String getTaxonomy() { setupAll return super.getTaxonomy(); }
	//
	public Category getCategory(final String catName) { getChildren(); return super.getCategory(catName); }
	public List<Category> getLeafCats() { getChildren(); return super.getLeafCats(); }
	public void readInCurrentRSSFeed() { getChildren(); super.readInCurrentRSSFeed(); }
	public void updateRSSFeed() { getChildren(); super.updateRSSFeed(); }
	public void freeRSSFeed() { getChildren(); super.freeRSSFeed(); }
	public void invalidateRSSFeed() { getChildren(); super.invalidateRSSFeed(); }
}
