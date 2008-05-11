package newsrack.database.sql;

import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;

import java.sql.*;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import newsrack.util.Tuple;
import newsrack.util.Triple;
import newsrack.archiver.Feed;
import newsrack.archiver.Source;
import newsrack.database.DB_Interface;
import newsrack.filter.Concept;
import newsrack.filter.ConceptToken;
import newsrack.filter.Category;
import newsrack.filter.Filter;
import newsrack.filter.Filter.*;
import newsrack.filter.Issue;
import newsrack.user.User;
import newsrack.filter.NR_CollectionType;
import newsrack.filter.NR_Collection;
import newsrack.filter.NR_SourceCollection;
import newsrack.filter.NR_ConceptCollection;
import newsrack.filter.NR_FilterCollection;
import newsrack.filter.NR_CategoryCollection;

import static newsrack.filter.NR_CollectionType.*;
import static newsrack.filter.Filter.FilterOp.*;
import static newsrack.database.sql.SQL_ValType.*;
import static newsrack.database.sql.SQL_ColumnSize.*;

class GetCollectionResultProcessor extends AbstractResultProcessor
{
	// @FIXME: Assumes that this won't be called for multiple values!
	Long   _cKey;
	Long   _uKey;
	String _name;
	NR_CollectionType _cType;

	public ResultProcessor getNewInstance() { return new GetCollectionResultProcessor(); }

	public Object processResultSet(ResultSet rs) throws java.sql.SQLException
	{
		_cKey  = rs.getLong(1);
		_name  = rs.getString(2);
		_cType = NR_CollectionType.getType(rs.getString(3));
		_uKey  = rs.getLong(4);
		return null;
	}

	public Object processOutput(Object o)
	{
			// Check the query returned zero results.
		if (_cKey == null)
			return null;

		NR_Collection c = null;
		switch (_cType) {
			case SOURCE :
				c = new NR_SourceCollection(SQL_Stmt._db.getUser(_uKey), _name, null);
				c.setKey(_cKey);
				break;

			case CONCEPT :
				c = new NR_ConceptCollection(SQL_Stmt._db.getUser(_uKey), _name, null);
				c.setKey(_cKey);
				break;

			case CATEGORY :
				c = new NR_CategoryCollection(SQL_Stmt._db.getUser(_uKey), _name, null);
				c.setKey(_cKey);
				break;

			case FILTER :
				c = new NR_FilterCollection(SQL_Stmt._db.getUser(_uKey), _name, null);
				c.setKey(_cKey);
				break;

			default:
				SQL_Stmt._log.error("Unsupported collection type: " + _cType);
				break;
		}
		return c;
	}
}

class GetNewsIndexResultProcessor extends AbstractResultProcessor
{
	public Object processResultSet(ResultSet rs) throws java.sql.SQLException { return new SQL_NewsIndex(rs.getLong(1), rs.getString(2)); }
}

class GetUserResultProcessor extends AbstractResultProcessor
{
	public Object processResultSet(ResultSet rs) throws SQLException
	{
		User u = new User(rs.getString(2), rs.getString(3), rs.getBoolean(6));
		u.setKey(rs.getLong(1));
		u.setName(rs.getString(4));
		u.setEmail(rs.getString(5));
		return u;
	}
}

class GetIssueResultProcessor extends AbstractResultProcessor
{
	public Object processResultSet(ResultSet rs) throws SQLException
	{
		return new SQL_IssueStub(rs.getLong(1), rs.getLong(2), rs.getString(3), rs.getInt(4), rs.getTimestamp(5), rs.getBoolean(6), rs.getBoolean(7), rs.getBoolean(8), rs.getString(9));
	}
}

class GetConceptTupleResultProcessor extends AbstractResultProcessor
{
	public Object processResultSet(ResultSet rs) throws SQLException
	{
		return new Tuple<Long, Concept>(rs.getLong(1), new SQL_ConceptStub(rs.getLong(2), rs.getString(3), rs.getString(4), rs.getString(5)));
	}
}

class GetConceptResultProcessor extends AbstractResultProcessor
{
	public Object processResultSet(ResultSet rs) throws SQLException
	{
		return new SQL_ConceptStub(rs.getLong(1), rs.getString(2), rs.getString(3), rs.getString(4));
	}
}

/**
 * Okay, here is how things work with rule trees.
 * - rule terms are mapped as <cat-key, op-type, left-term-key, right-term-key> tuples in the DB.
 * - right-term-key might be null for single-operand terms.
 * - context terms pose problems ... the context list has to be encoded.
 *   it is done as <cat-key, -1, context-term-key, concept-key> tuples.
 *   so, if we run into a -1 op-type, recover the concept-key and start building
 *   the context list.
 */
class GetFilterResultProcessor extends AbstractResultProcessor
{
	private List<Object[]> _interimResults = new ArrayList<Object[]>();
	private boolean _getUserKey;
	private Long    _userKey;

	public GetFilterResultProcessor(boolean getUserKey)
	{
		_getUserKey = getUserKey;
	}

	public ResultProcessor getNewInstance() { return new GetFilterResultProcessor(_getUserKey); }

	public Object processResultSet(ResultSet rs) throws SQLException
	{
			// IMPORTANT: processResultSet methods *should complete* WITHOUT attempting 
			// to acquire additional db resources!  Otherwise, we  will deadlock.
		_interimResults.add(new Object[] {rs.getLong(1), rs.getString(2), rs.getString(3), rs.getLong(4)});
		if (_getUserKey)
			_userKey = rs.getLong(5);
		return null;
	}

	private RuleTerm buildRuleTree(Long termKey, Map<Long, Object[]> rtMap, Map<Long, List> contextMap)
	{
		Object[] rtVals = rtMap.get(termKey);
		FilterOp op     = Filter.getTermType((Integer)rtVals[1]);
		switch(op) {
			case LEAF_CONCEPT:
				return new Filter.LeafConcept(SQL_Stmt._db.getConcept((Long)rtVals[2]));

			case LEAF_FILTER:
				return new Filter.LeafFilter(SQL_Stmt._db.getFilter((Long)rtVals[2]));

			case LEAF_CAT:
				return new Filter.LeafCategory(SQL_Stmt._db.getCategory((Long)rtVals[2]));

			case NOT_TERM:
				return new Filter.NegTerm(buildRuleTree((Long)rtVals[2], rtMap, contextMap));

			case CONTEXT_TERM:
				return new Filter.ContextTerm(buildRuleTree((Long)rtVals[2], rtMap, contextMap), contextMap.get(termKey));

			case AND_TERM:
			case OR_TERM:
				return new Filter.NonLeafTerm(op, buildRuleTree((Long)rtVals[2], rtMap, contextMap), buildRuleTree((Long)rtVals[3], rtMap, contextMap));
		}

		SQL_Stmt._log.error("Fallen out of Ruleterm switch!  Should not have happened!  Investigate!");
		return null;
	}

	private Filter buildFilter(Object[] sqlRowVals)
	{
		List<Object[]>      ruleTerms = (List<Object[]>)SQL_Stmt.GET_FILTER_TERMS.execute(new Object[] {(Long)sqlRowVals[0]});
		Map<Long, List>     ctxtMap   = new HashMap<Long, List>();
		Map<Long, Object[]> rtMap     = new HashMap<Long, Object[]>();
		for (Object[] rtVals: ruleTerms) {
			rtMap.put((Long)rtVals[0], rtVals);
				// Set up context concept lists for those rule term tuples 
				// for which the op-type value is -1
			if (((Integer)rtVals[1]) == -1) {
				List context = ctxtMap.get((Long)rtVals[2]);
				if (context == null) {
					context = new ArrayList<Long>();
					ctxtMap.put((Long)rtVals[2], context);
				}
				context.add(SQL_Stmt._db.getConcept((Long)rtVals[3]));
			}
		}

		return new Filter((String)sqlRowVals[1], (String)sqlRowVals[2], buildRuleTree((Long)sqlRowVals[3], rtMap, ctxtMap));
	}

	public Object processOutput(Object o)
	{
		if (_interimResults.isEmpty()) {
			return null;
		}
		else {
			Filter f = buildFilter(_interimResults.get(0));
			return (_getUserKey) ? new Tuple<Long, Filter>(_userKey, f) : f;
		}
	}

	public List processOutputList(List l)
	{
		List filters = new ArrayList();
		for (Object[] sqlRowVals: _interimResults)
			filters.add(buildFilter(sqlRowVals));

		return filters;
	}
}

class GetCategoryResultProcessor extends AbstractResultProcessor
{
	private boolean _getNewsInfo;
	private boolean _buildRuleTree;
	private boolean _buildTaxonomy;
	private List<Tuple<Category, Long>> _interimResults;
	private Map<Long, Category> _catMap;	// cat key --> category
	private Map<Long, Long> _parentMap;		// cat key --> parent cat key
	private Long _userKey;

	public GetCategoryResultProcessor(boolean getNewsInfo, boolean getFilter, boolean getParent) 
	{
		_getNewsInfo   = getNewsInfo;
		_buildRuleTree = getFilter;
		_buildTaxonomy = getParent;
		if (_buildTaxonomy) {
			_catMap    = new HashMap<Long, Category>();
			_parentMap = new HashMap<Long, Long>();
		}
		if (_buildRuleTree) {
			_interimResults = new ArrayList<Tuple<Category, Long>>();
		}
	}

	public ResultProcessor getNewInstance() { return new GetCategoryResultProcessor(_getNewsInfo, _buildRuleTree, _buildTaxonomy); }

	public Object processResultSet(ResultSet rs) throws SQLException
	{
			// IMPORTANT: processResultSet methods *should complete* WITHOUT attempting
			// to acquire additional db resources!  Otherwise, we will deadlock.
		_userKey = rs.getLong(6);
		long filtKey = rs.getLong(5);
		if (filtKey == 0)
			filtKey = (long)-1;

		Category c = (_buildRuleTree) ? new Category(rs.getLong(1), rs.getString(2), null, rs.getInt(3))
		                              : new SQL_CategoryStub(_userKey, rs.getLong(1), rs.getString(2), rs.getInt(3), rs.getLong(4), filtKey);
		if (_getNewsInfo) {
			c.setNumArticles(rs.getInt(8));
			c.setLastUpdateTime(rs.getTimestamp(9));
			if (!_buildRuleTree) /* In the build rule tree case, the issue info will be set elsewhere */
				((SQL_CategoryStub)c).setIssueKey(rs.getLong(7));
			c.setTaxonomyPath(rs.getString(10));
		}

		if (_buildTaxonomy) {
			_parentMap.put(c.getKey(), rs.getLong(4));
			_catMap.put(c.getKey(), c);
		}

		if (_buildRuleTree)
			_interimResults.add(new Tuple<Category,Long>(c, filtKey));

		return c;
	}

	public Object processOutput(Object o)
	{
		if (_buildRuleTree && !_interimResults.isEmpty()) {
				// set up filter for the category
				// note that o will be the same as t._a
			Tuple<Category, Long> t = _interimResults.get(0);
			if (t._b != -1)
				t._a.setFilter((Filter)SQL_Stmt.GET_FILTER_FOR_CAT.execute(new Object[]{t._b}));
		}
		return new Tuple<Long, Category>(_userKey, (Category)o);
	}

	public List processOutputList(List l)
	{
		if (_buildRuleTree) {
				// set up filters for all the categories
			for (Tuple<Category, Long> t: _interimResults) {
				t._a.setFilter((Filter)SQL_Stmt.GET_FILTER_FOR_CAT.execute(new Object[]{t._b}));
			}
		}
		if (_buildTaxonomy) {
			List<Category> catList = (List<Category>)l;
			for (Category c: catList) {
				Long parentKey = _parentMap.get(c.getKey());
				if (parentKey != -1) {
					Category parent = _catMap.get(parentKey);
					c.setParent(parent);
					parent.addChild(c);
				}
			}
		}

		return l;
	}
}

class GetFeedResultProcessor extends AbstractResultProcessor
{
	public Object processResultSet(ResultSet rs) throws java.sql.SQLException
	{
		Long   feedKey   = rs.getLong(1);
		String feedTag   = rs.getString(2);
		String feedName  = rs.getString(3);
		String rssFeed   = rs.getString(4) + rs.getString(5);
		// FIXME: Can this logic of appending these two elements be moved to the Feed class somehow??
		Feed f = new Feed(feedKey, feedKey + "." + feedTag, feedName, rssFeed);
		f.setCacheableFlag(rs.getBoolean(6));
		f.setShowCachedTextDisplayFlag(rs.getBoolean(7));
		return f;
	}
}

class GetSourceResultProcessor extends AbstractResultProcessor
{
	public Object processResultSet(ResultSet rs) throws java.sql.SQLException {
		Long    srcKey    = rs.getLong(1);
		Long    userKey   = rs.getLong(2);
		Long    feedKey   = rs.getLong(3);
		String  srcName   = rs.getString(4);
		String  srcTag    = rs.getString(5);
		boolean cacheable = rs.getBoolean(6);
		boolean showCacheLinks = rs.getBoolean(7);
		return new SQL_SourceStub(srcKey, feedKey, userKey, srcName, srcTag, cacheable, showCacheLinks);
	}
}

class GetNewsItemResultProcessor extends AbstractResultProcessor
{
	public Object processResultSet(ResultSet rs) throws java.sql.SQLException
	{
		String urlRoot   = rs.getString(3);
		String urlTail   = rs.getString(4);
		String localName = rs.getString(5);
		String title     = rs.getString(6);
		String desc      = rs.getString(7);
		String author    = rs.getString(8);
		String dateStr   = rs.getString(9);
		Long   feedKey   = rs.getLong(10);
		SQL_NewsItem ni = new SQL_NewsItem(urlRoot, urlTail, localName, title, desc, author, feedKey, dateStr);
		ni.setKey(rs.getLong(2));
		ni.setNewsIndexKey(rs.getLong(1));

		return ni;
	}
}

public enum SQL_Stmt 
{
   GET_NEWS_ITEM_WITH_FEED_SOURCE_FROM_URL(
		"SELECT n1.primary_ni_key, n1.n_key, n1.url_root, n1.url_tail, n1.cached_item_name, n1.title, n1.description, n1.author, n2.date_string, n2.feed_key" +
			" FROM news_item_table n1, news_index_table n2" +
			" WHERE n1.url_root = ? AND n1.url_tail = ? AND n1.primary_ni_key = n2.ni_key",
		new SQL_ValType[] {STRING, STRING},
      SQL_StmtType.QUERY,
		null,
		new GetNewsItemResultProcessor(),
		false
	),
   GET_NEWS_ITEM_WITH_FEED_SOURCE_FROM_CACHEDNAME(
		"SELECT n1.primary_ni_key, n1.n_key, n1.url_root, n1.url_tail, n1.cached_item_name, n1.title, n1.description, n1.author, n2.date_string, n2.feed_key" +
			" FROM news_item_table n1, news_index_table n2, feed_table f " +
			" WHERE n1.cached_item_name = ? AND n2.date_string = ? AND f.feed_tag = ?",
		new SQL_ValType[] {STRING, STRING, STRING},
      SQL_StmtType.QUERY,
		null,
		new GetNewsItemResultProcessor(),
		true
	),
	GET_NEWS_INDEX_BY_KEY(
		"SELECT ni_key, date_string FROM news_index_table WHERE ni_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.QUERY,
		null,
		new GetNewsIndexResultProcessor(),
		true
	),
	GET_NEWS_INDEX_KEY(
		"SELECT ni_key FROM news_index_table WHERE feed_key = ? AND date_string = ?",
		new SQL_ValType[] {LONG, STRING},
      SQL_StmtType.QUERY,
		null,
		new GetLongResultProcessor(),
		true
	),
	GET_NEWS_INDEX(
		"SELECT ni_key, date_string FROM news_index_table WHERE feed_key = ? AND date_string = ?",
		new SQL_ValType[] {LONG, STRING},
      SQL_StmtType.QUERY,
		null,
		new GetNewsIndexResultProcessor(),
		true
	),
	GET_ALL_NEWS_INDEXES_FROM_FEED_ID(
		"SELECT ni_key, date_string FROM news_index_table n WHERE n.feed_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.QUERY,
		null,
		new GetNewsIndexResultProcessor(),
		false
	),
	CAT_NEWSITEM_PRESENT(
		"SELECT c_key FROM cat_news_table WHERE c_key = ? AND n_key = ? AND ni_key = ?",
		new SQL_ValType[] {LONG, LONG, LONG},
      SQL_StmtType.QUERY,
		null,
		new AbstractResultProcessor() {
			public Object processResultSet(ResultSet rs) throws java.sql.SQLException { return new Boolean(true); }
		},
		true
	),
	GET_NEWS_FROM_CAT(
		"SELECT n.primary_ni_key, n.n_key, n.url_root, n.url_tail, n.cached_item_name, n.title, n.description, n.author, ni.date_string, ni.feed_key" +
		   " FROM  news_item_table n, news_index_table ni, cat_news_table cn" +
		   " WHERE (cn.c_key = ?) AND (cn.n_key = n.n_key) AND (cn.ni_key = ni.ni_key) " +
		   " ORDER BY ni.date_stamp DESC, cn.n_key DESC LIMIT ?, ?",
		new SQL_ValType[] {LONG, INT, INT},
      SQL_StmtType.QUERY,
		null,
		new GetNewsItemResultProcessor(),
		false
	),
	GET_CATS_FOR_NEWSITEM(
		"SELECT c.cat_key, c.name, c.cat_id, c.parent_cat, c.f_key, c.u_key, c.t_key, c.num_articles, c.last_update, c.taxonomy_path FROM cat_news_table cn, cat_table c WHERE n_key = ? AND cn.c_key = c.cat_key AND c.valid = true",
		new SQL_ValType[] {LONG},
      SQL_StmtType.QUERY,
		null,
		new GetCategoryResultProcessor(true, false, false),
		false
	),
	GET_FILTER_TERMS(
		"SELECT rt_key, term_type, arg1_key, arg2_key FROM filter_rule_term_table WHERE f_key = ? ",
		new SQL_ValType[] {LONG},
      SQL_StmtType.QUERY,
		null,
		new AbstractResultProcessor() {
			public Object processResultSet(ResultSet rs) throws java.sql.SQLException { return new Object[]{rs.getLong(1), rs.getInt(2), rs.getLong(3), rs.getLong(4)}; }
		},
		false
	),
	GET_ALL_FILTER_KEYS_FOR_USER(
		"SELECT f_key FROM filter_table WHERE u_key = ? ",
		new SQL_ValType[] {LONG},
      SQL_StmtType.QUERY,
		null,
		new GetLongResultProcessor(),
		false
	),
	GET_CAT_KEYS_FOR_NEWSITEM(
		"SELECT c_key FROM cat_news_table WHERE n_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.QUERY,
		null,
		new GetLongResultProcessor(),
		false
	),
	GET_CATCOUNT_FOR_NEWSITEM(
		"SELECT COUNT(n_key) FROM cat_news_table WHERE n_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.QUERY,
		null,
		new GetIntResultProcessor(),
		true
	),
      // MERGING the 2 queries into a single one using OR gives
      // very very bad timing!  It is better to run the 2 queries
      // as independent ones and union the result sets
	GET_NEWS_FROM_NEWSINDEX(
		"SELECT n.primary_ni_key, n.n_key, n.url_root, n.url_tail, n.cached_item_name, n.title, n.description, n.author, ni.date_string, ni.feed_key" +
		   " FROM  news_item_table n, news_index_table ni" +
		   " WHERE (n.primary_ni_key = ? AND n.primary_ni_key = ni.ni_key) " +
		   " UNION " +
		"SELECT n.primary_ni_key, n.n_key, n.url_root, n.url_tail, n.cached_item_name, n.title, n.description, n.author, ni.date_string, ni.feed_key" +
		   " FROM  news_item_table n, news_index_table ni, news_collections_table sn" +
		   " WHERE (sn.ni_key = ? AND sn.n_key = n.n_key AND n.primary_ni_key = ni.ni_key)",
		new SQL_ValType[] {LONG, LONG},
      SQL_StmtType.QUERY,
		null,
		new GetNewsItemResultProcessor(),
		false
	),
	GET_FEED_BY_KEY(
		"SELECT feed_key, feed_tag, feed_name, url_root, url_tail, cacheable, show_cache_links FROM feed_table WHERE feed_key = ?",
      new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new GetFeedResultProcessor(),
		true
	),
	GET_ALL_FEEDS(
		"SELECT feed_key, feed_tag, feed_name, url_root, url_tail, cacheable, show_cache_links FROM feed_table",
      new SQL_ValType[] {},
		SQL_StmtType.QUERY,
		null,
		new GetFeedResultProcessor(),
		false
	),
	GET_SOURCE_BY_KEY(
		"SELECT src_key, u_key, feed_key, src_name, src_tag, cacheable, show_cache_links FROM user_source_table WHERE src_key = ?",
      new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new GetSourceResultProcessor(),
		true
	),
	GET_USER_SOURCE(
		"SELECT src_key, u_key, feed_key, src_name, src_tag, cacheable, show_cache_links FROM user_source_table WHERE u_key = ? AND src_tag = ?",
      new SQL_ValType[] {LONG, STRING},
		SQL_StmtType.QUERY,
		null,
		new GetSourceResultProcessor(),
		true
	),
   GET_UNIQUE_FEED_TAG(
		"SELECT feed_key, feed_tag FROM feed_table WHERE url_root = ? AND url_tail = ?",
      new SQL_ValType[] {STRING, STRING},
		SQL_StmtType.QUERY,
		null,
		new AbstractResultProcessor() {
				// FIXME: Can this logic of appending these two elements be moved to the Feed class somehow??
         public Object processResultSet(ResultSet rs) throws java.sql.SQLException { return rs.getLong(1) + "." + rs.getString(2); }
      },
		true
	),
   GET_USER_FROM_UID(
      "SELECT * FROM user_table WHERE uid = ?",	// simpler to select all fields rather than ignoring a single field
      new SQL_ValType[] {STRING},
		SQL_StmtType.QUERY,
		null,
      new GetUserResultProcessor(),
		true
   ),
   GET_USER_BY_KEY(
      "SELECT * FROM user_table WHERE u_key = ?",	// simpler to select all fields rather than ignoring a single field
      new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
      new GetUserResultProcessor(),
		true
   ),
   GET_ALL_USERS(
      "SELECT * FROM user_table ORDER BY uid",
      new SQL_ValType[] {},
		SQL_StmtType.QUERY,
		null,
      new GetUserResultProcessor(),
		false
   ),
	GET_ISSUE_INFO(
      "SELECT t_key, num_articles, last_update FROM topic_table WHERE name = ? AND u_key = ?",
      new SQL_ValType[] {STRING, LONG},
		SQL_StmtType.QUERY,
		null,
		new AbstractResultProcessor() {
			public Object processResultSet(ResultSet rs) throws java.sql.SQLException { return new Triple(rs.getLong(1), rs.getInt(2), rs.getTimestamp(3)); }
		},
		true
	),
	GET_CAT_INFO(
		"SELECT cat_key, num_articles, last_update FROM cat_table WHERE t_key = ? AND cat_id = ?",
      new SQL_ValType[] {LONG, INT},
		SQL_StmtType.QUERY,
		null,
		new AbstractResultProcessor() {
			public Object processResultSet(ResultSet rs) throws java.sql.SQLException { return new Triple(rs.getLong(1), rs.getInt(2), rs.getTimestamp(3)); }
		},
		true
	),
   GET_ISSUE_BY_KEY(
      "SELECT * FROM topic_table WHERE t_key = ?",
      new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new GetIssueResultProcessor(),
		true
   ),
   GET_ISSUE_BY_USER_KEY(
      "SELECT * FROM topic_table WHERE u_key = ? AND name = ?",
      new SQL_ValType[] {LONG, STRING},
		SQL_StmtType.QUERY,
		null,
		new GetIssueResultProcessor(),
		true
   ),
   GET_ISSUE_BY_USER_ID(
      "SELECT * FROM topic_table t, user_table u WHERE u.uid = ? AND t.u_key = u.u_key AND name = ?",
      new SQL_ValType[] {STRING, STRING},
		SQL_StmtType.QUERY,
		null,
		new GetIssueResultProcessor(),
		true
   ),
   GET_ALL_ISSUES_BY_USER_KEY(
      "SELECT * FROM topic_table WHERE u_key = ? ORDER BY lower(name)",
      new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new GetIssueResultProcessor(),
		false
   ),
	GET_CATS_FOR_ISSUE(
		"SELECT cat_key, name, cat_id, parent_cat, f_key, u_key, t_key, num_articles, last_update, taxonomy_path FROM cat_table WHERE t_key = ? AND valid = true",
		new SQL_ValType[] {LONG},
      SQL_StmtType.QUERY,
		null,
		new GetCategoryResultProcessor(true, false, true),
		false
	),
   GET_ALL_VALIDATED_ISSUES(
      "SELECT * FROM topic_table where validated = true ORDER BY lower(name)",
      new SQL_ValType[] {},
		SQL_StmtType.QUERY,
		null,
		new GetIssueResultProcessor(),
		false
   ),
   GET_ALL_ISSUES(
      "SELECT * FROM topic_table ORDER BY lower(name)",
      new SQL_ValType[] {},
		SQL_StmtType.QUERY,
		null,
		new GetIssueResultProcessor(),
		false
   ),
	GET_IMPORTING_USERS(
		"SELECT importing_user_key FROM import_dependency_table WHERE from_user_key = ?",
      new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new GetLongResultProcessor(),
		false
	),
	GET_COLLECTION(
		"SELECT * FROM user_collections_table WHERE uid = ? AND coll_name = ? AND coll_type = ?",
      new SQL_ValType[] {STRING, STRING, STRING},
		SQL_StmtType.QUERY,
		null,
		new GetCollectionResultProcessor(),
		true
	),
	GET_ALL_COLLECTIONS_OF_TYPE(
		"SELECT * FROM user_collections_table WHERE coll_type = ?",
      new SQL_ValType[] {STRING},
		SQL_StmtType.QUERY,
		null,
		new GetCollectionResultProcessor(),
		false
	),
	GET_ALL_COLLECTIONS_OF_TYPE_FOR_USER(
		"SELECT * FROM user_collections_table WHERE coll_type = ? AND uid = ?",
      new SQL_ValType[] {STRING, STRING},
		SQL_StmtType.QUERY,
		null,
		new GetCollectionResultProcessor(),
		false
	),
   GET_ALL_FILES_BY_USER_KEY(
      "SELECT file_name FROM user_files_table WHERE u_key = ? ORDER BY add_time",
      new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new AbstractResultProcessor() {
			public Object processResultSet(ResultSet rs) throws java.sql.SQLException { return rs.getString(1); }
		},
		false
   ),
	GET_ALL_SOURCES_FROM_USER_COLLECTION(
		"SELECT s.src_key, s.u_key, s.feed_key, s.src_name, s.src_tag, s.cacheable, s.show_cache_links FROM user_source_table s, collection_entries_table ce WHERE ce.coll_key = ? AND ce.entry_key = s.src_key",
		new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new GetSourceResultProcessor(),
		false
	),
	GET_SOURCE_FROM_USER_COLLECTION(
		"SELECT s.src_key, s.u_key, s.feed_key, s.src_name, s.src_tag, s.cacheable, s.show_cache_links FROM user_source_table s, collection_entries_table ce WHERE ce.coll_key = ? AND s.src_tag = ? AND ce.entry_key = s.src_key",
		new SQL_ValType[] {LONG, STRING},
		SQL_StmtType.QUERY,
		null,
		new GetSourceResultProcessor(),
		true
	),
	GET_MONITORED_SOURCES_FOR_TOPIC(
		"SELECT s.src_key, s.u_key, s.feed_key, s.src_name, s.src_tag, s.cacheable, s.show_cache_links FROM topic_source_table t, user_source_table s WHERE t.t_key = ? AND t.src_key = s.src_key ORDER BY lower(s.src_name)",
		new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new GetSourceResultProcessor(),
		false
	),
	GET_ALL_MONITORED_SOURCES_FOR_USER(
		"SELECT s.src_key, s.u_key, s.feed_key, s.src_name, s.src_tag, s.cacheable, s.show_cache_links FROM user_source_table s WHERE s.u_key = ? ORDER BY lower(s.src_name)",
		new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new GetSourceResultProcessor(),
		false
	),
	GET_TOPIC_SOURCE_ROW(
	   "SELECT max_ni_key FROM topic_source_table WHERE t_key = ? AND feed_key = ? ORDER BY src_key",
		new SQL_ValType[] {LONG, LONG},
		SQL_StmtType.QUERY,
		null,
		new GetLongResultProcessor(),
		false
	),
	GET_CONCEPT_BY_KEY(
		"SELECT u_key, cpt_key, name, defn, token FROM concept_table WHERE cpt_key = ?",
		new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new GetConceptTupleResultProcessor(),
		true
	),
	GET_CONCEPT_FROM_USER_COLLECTION(
		"SELECT c.u_key, c.cpt_key, c.name, c.defn, c.token FROM concept_table c, collection_entries_table ce WHERE ce.coll_key = ? AND ce.entry_key = c.cpt_key AND c.name = ?",
		new SQL_ValType[] {LONG, STRING},
		SQL_StmtType.QUERY,
		null,
		new GetConceptTupleResultProcessor(),
		true
	),
	GET_ALL_CONCEPTS_FROM_USER_COLLECTION(
		"SELECT c.u_key, c.cpt_key, c.name, c.defn, c.token FROM concept_table c, collection_entries_table ce WHERE ce.coll_key = ? AND ce.entry_key = c.cpt_key",
		new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new GetConceptResultProcessor(),
		false
	),
	GET_ALL_FILTERS_FROM_USER_COLLECTION(
		"SELECT f.f_key, f.name, f.rule_string, f.rule_key FROM filter_table f, collection_entries_table ce WHERE ce.coll_key = ? AND ce.entry_key = f.f_key",
		new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new GetFilterResultProcessor(false),
		false
	),
	GET_FILTER_FROM_USER_COLLECTION(
		"SELECT f.f_key, f.name, f.rule_string, f.rule_key, f.u_key FROM filter_table f, collection_entries_table ce WHERE ce.coll_key = ? AND ce.entry_key = f.f_key AND f.name = ?",
		new SQL_ValType[] {LONG, STRING},
		SQL_StmtType.QUERY,
		null,
		new GetFilterResultProcessor(true),
		true
	),
	GET_FILTER_FOR_CAT(
		"SELECT f_key, name, rule_string, rule_key FROM filter_table WHERE f_key = ? ",
		new SQL_ValType[] {LONG},
      SQL_StmtType.QUERY,
		null,
		new GetFilterResultProcessor(false),
		true
	),
	GET_FILTER_BY_KEY(
		"SELECT f_key, name, rule_string, rule_key, u_key FROM filter_table WHERE f_key = ?",
		new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new GetFilterResultProcessor(true),
		true
	),
	GET_ALL_CATEGORIES_FROM_USER_COLLECTION(
		"SELECT c.cat_key, c.name, c.cat_id, c.parent_cat, c.f_key, c.u_key FROM cat_table c, collection_entries_table ce WHERE ce.coll_key = ? AND ce.entry_key = c.cat_key",
		new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new GetCategoryResultProcessor(false, true, true),
		false
	),
	GET_CATEGORY_FROM_USER_COLLECTION(
		"SELECT c.cat_key, c.name, c.cat_id, c.parent_cat, c.f_key, c.u_key FROM cat_table c, collection_entries_table ce WHERE ce.coll_key = ? AND ce.entry_key = c.cat_key AND c.name = ? AND c.parent_cat = ?",
		new SQL_ValType[] {LONG, STRING, LONG},
		SQL_StmtType.QUERY,
		null,
		new GetCategoryResultProcessor(false, true, false),
		true
	),
	GET_CATEGORY_BY_KEY(
		"SELECT cat_key, name, cat_id, parent_cat, f_key, u_key, t_key, num_articles, last_update, taxonomy_path FROM cat_table WHERE cat_key = ?",
		new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new GetCategoryResultProcessor(true, false, false),
		true
	),
	GET_NESTED_CATS(
		"SELECT cat_key, name, cat_id, parent_cat, f_key, t_key, num_articles, last_update, taxonomy_path FROM cat_table WHERE c.parent_cat = ?",
		new SQL_ValType[] {LONG},
		SQL_StmtType.QUERY,
		null,
		new GetCategoryResultProcessor(true, false, false),
		false
	),
	GET_NESTED_CATS_FROM_USER_COLLECTION(
		"SELECT c.cat_key, c.name, c.cat_id, c.parent_cat, c.f_key FROM cat_table c, collection_entries_table ce WHERE ce.coll_key = ? AND ce.entry_key = c.cat_key AND c.parent_cat = ?",
		new SQL_ValType[] {LONG, LONG},
		SQL_StmtType.QUERY,
		null,
		new GetCategoryResultProcessor(false, true, false),
		false
	),
   GET_ALL_PUBLIC_FILES(
      "SELECT file_name FROM user_files_table ORDER BY file_name",
      new SQL_ValType[] {},
		SQL_StmtType.QUERY,
		null,
		new AbstractResultProcessor() {
			public Object processResultSet(ResultSet rs) throws java.sql.SQLException { return rs.getString(1); }
		},
		false
   ),
	GET_ALL_ACTIVE_FEEDS(
	   "SELECT feed_key, feed_tag, feed_name, url_root, url_tail, cacheable, show_cache_links FROM feed_table WHERE feed_key IN (SELECT distinct feed_key FROM topic_source_table)",
		new SQL_ValType[] {},
		SQL_StmtType.QUERY,
		null,
		new GetFeedResultProcessor(),
		false
	),
		// Prepared Statement Strings for INSERTs 
   INSERT_USER(
		"INSERT INTO user_table (uid, password, name, email) VALUES (?,?,?,?)",
		new SQL_ValType[] {STRING, STRING, STRING, STRING},
      SQL_StmtType.INSERT,
      new SQL_ColumnSize[] {USER_TBL_UID, USER_TBL_PASSWORD, USER_TBL_NAME, USER_TBL_EMAIL},
		new GetLongResultProcessor(),
		true
   ),
	INSERT_TOPIC(
		"INSERT INTO topic_table (u_key, name, validated, frozen, private, taxonomy_path) VALUES (?,?,?,?,?,?)",
		new SQL_ValType[] {LONG, STRING, BOOLEAN, BOOLEAN, BOOLEAN, STRING},
      SQL_StmtType.INSERT,
		null,
		new GetLongResultProcessor(),
		true
	),
   INSERT_FEED(
		"INSERT INTO feed_table (feed_tag, feed_name, url_root, url_tail) VALUES (?,?,?,?)",
		new SQL_ValType[] {STRING, STRING, STRING, STRING},
      SQL_StmtType.INSERT,
      new SQL_ColumnSize[] {FEED_TBL_FEEDTAG, NONE, FEED_TBL_FEEDURLROOT, FEED_TBL_FEEDURLTAIL},
		new GetLongResultProcessor(),
		true
	),
	INSERT_NEWS_INDEX(
		"INSERT INTO news_index_table (feed_key, date_string, date_stamp) VALUES (?,?,?)",
      new SQL_ValType[] {LONG, STRING, TIMESTAMP},
		SQL_StmtType.INSERT,
		new SQL_ColumnSize[] {NONE, NEWS_INDEX_TBL_DATESTRING, NONE},
		new GetLongResultProcessor(),
		true
	),
	INSERT_NEWS_ITEM(
		"INSERT INTO news_item_table (primary_ni_key, url_root, url_tail, cached_item_name, title, description, author) VALUES (?,?,?,?,?,?,?)",
      new SQL_ValType[] {LONG, STRING, STRING, STRING, STRING, STRING, STRING},
		SQL_StmtType.INSERT,
		new SQL_ColumnSize[] {NONE, NEWS_ITEM_TBL_URLROOT, NEWS_ITEM_TBL_URLTAIL, NEWS_ITEM_TBL_LOCALNAME, NONE, NONE, NONE},
		new GetLongResultProcessor(),
		true
	),
	INSERT_INTO_SHARED_NEWS_TABLE(
		"INSERT INTO news_collections_table (ni_key, n_key) VALUES (?, ?)",
		new SQL_ValType[] {LONG, LONG},
      SQL_StmtType.INSERT,
      null,
		null,
		true
	),
	INSERT_CAT(
		"INSERT INTO cat_table (name, u_key, t_key, cat_id, parent_cat, f_key, taxonomy_path) VALUES (?,?,?,?,?,?,?)",
      new SQL_ValType[] {STRING, LONG, LONG, INT, LONG, LONG, STRING},
		SQL_StmtType.INSERT,
      new SQL_ColumnSize[] {CAT_TBL_NAME, NONE, NONE, NONE, NONE, NONE, NONE},
		new GetLongResultProcessor(),
		true
	),
	INSERT_RULE_TERM(
		"INSERT INTO filter_rule_term_table (f_key, term_type, arg1_key, arg2_key) VALUES (?,?,?,?)",
      new SQL_ValType[] {LONG, INT, LONG,  LONG},
		SQL_StmtType.INSERT,
      null,
		new GetLongResultProcessor(),
		true
	),
	INSERT_INTO_CAT_NEWS_TABLE(
		"INSERT INTO cat_news_table (c_key, n_key, ni_Key) VALUES (?,?,?)",
		new SQL_ValType[] {LONG, LONG, LONG},
      SQL_StmtType.INSERT,
		null,
		new GetLongResultProcessor(),
		true
	),
	INSERT_USER_FILE(
		"INSERT INTO user_files_table (u_key, file_name) VALUES (?, ?)",
		new SQL_ValType[] {LONG, STRING},
      SQL_StmtType.INSERT,
		null,
		null,
		true
	),
	INSERT_IMPORT_DEPENDENCY(
	   "INSERT IGNORE INTO import_dependency_table (from_user_key, importing_user_key) VALUES (?, ?)",
		new SQL_ValType[] {LONG, LONG},
      SQL_StmtType.INSERT,
		null,
		null,
		true
	),
	INSERT_COLLECTION(
		"INSERT INTO user_collections_table (coll_name, coll_type, u_key, uid) VALUES (?, ?, ?, ?)",
		new SQL_ValType[] {STRING, STRING, LONG, STRING},
      SQL_StmtType.INSERT,
		null,
		new GetLongResultProcessor(),
		true
	),
	INSERT_ENTRY_INTO_COLLECTION(
		"INSERT INTO collection_entries_table (coll_key, entry_key) VALUES (?,?)",
		new SQL_ValType[] {LONG, LONG},
      SQL_StmtType.INSERT,
		null,
		new GetLongResultProcessor(),
		true
	),
	INSERT_CONCEPT(
		"INSERT INTO concept_table(u_key, name, defn, keywords) VALUES (?,?,?,?)",
		new SQL_ValType[] {LONG, STRING, STRING, STRING},
      SQL_StmtType.INSERT,
		null,
		new GetLongResultProcessor(),
		true
	),
	INSERT_FILTER(
		"INSERT INTO filter_table (u_key, name, rule_string) VALUES (?,?,?)",
		new SQL_ValType[] {LONG, STRING, STRING},
      SQL_StmtType.INSERT,
		null,
		new GetLongResultProcessor(),
		true
	),
	INSERT_USER_SOURCE(
		"INSERT INTO user_source_table (u_key, feed_key, src_name, src_tag, cacheable, show_cache_links) VALUES (?,?,?,?,?,?)",
		new SQL_ValType[] {LONG, LONG, STRING, STRING, BOOLEAN, BOOLEAN},
      SQL_StmtType.INSERT,
		null,
		new GetLongResultProcessor(),
		true
	),
	INSERT_TOPIC_SOURCE(
		"INSERT INTO topic_source_table (t_key, src_key, feed_key) VALUES (?,?,?)",
		new SQL_ValType[] {LONG, LONG, LONG},
      SQL_StmtType.INSERT,
		null,
		null,
		true
	),
		// Prepared Statement Strings for UPDATEs 
	UPDATE_USER(
		"UPDATE user_table SET password = ?, name = ?, email = ?, validated = ? WHERE u_key = ?",
      new SQL_ValType[] {STRING, STRING, STRING, BOOLEAN, LONG},
		SQL_StmtType.UPDATE,
		null,
		null,
		true
	),
	UPDATE_FEED_CACHEABILITY(
		"UPDATE feed_table SET cacheable = ?, show_cache_links = ? WHERE feed_key = ?",
      new SQL_ValType[] {BOOLEAN, BOOLEAN, LONG}, 
		SQL_StmtType.UPDATE,
		null,
		null,
		true
	),
   UPDATE_CONCEPT_TOKEN(
      "UPDATE concept_table SET token = ? WHERE cpt_key = ?",
		new SQL_ValType[] {STRING, LONG},
      SQL_StmtType.UPDATE,
		null,
		null,
		true
	),
	UPDATE_TOPIC_INFO(
      "UPDATE topic_table SET validated = ?, frozen = ?, private = ? WHERE t_key = ?",
		new SQL_ValType[] {BOOLEAN, BOOLEAN, BOOLEAN, LONG},
      SQL_StmtType.UPDATE,
		new SQL_ColumnSize[] {NONE},
		null,
		true
	),
	UPDATE_ARTCOUNT_FOR_TOPIC(
		"UPDATE topic_table SET num_articles = ?, last_update = ? WHERE t_key = ?",
      new SQL_ValType[] {INT, TIMESTAMP, LONG}, 
		SQL_StmtType.UPDATE,
		null,
		null,
		true
	),
	UPDATE_TOPIC_VALID_STATUS(
      "UPDATE topic_table SET validated = ? WHERE t_key = ?",
		new SQL_ValType[] {BOOLEAN, LONG},
      SQL_StmtType.UPDATE,
		new SQL_ColumnSize[] {NONE},
		null,
		true
	),
	UPDATE_TOPICS_VALID_STATUS_FOR_USER(
      "UPDATE topic_table SET validated = ? WHERE u_key = ?",
		new SQL_ValType[] {BOOLEAN, LONG},
      SQL_StmtType.UPDATE,
		new SQL_ColumnSize[] {NONE},
		null,
		true
	),
	UPDATE_TOPIC_SOURCE_INFO(
		"UPDATE topic_source_table SET max_ni_key = ? WHERE t_key = ? AND feed_key = ?",
		new SQL_ValType[] {LONG, LONG, LONG},
      SQL_StmtType.INSERT,
		null,
		null,
		true
	),
	RESET_ALL_TOPIC_SOURCES(
		"UPDATE topic_source_table SET max_ni_key = 0 WHERE t_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.INSERT,
		null,
		null,
		true
	),
	UPDATE_CAT_NEWS_INFO(
		"UPDATE cat_table SET num_articles = ?, last_update = ? WHERE cat_key = ?",
      new SQL_ValType[] {INT, TIMESTAMP, LONG}, 
		SQL_StmtType.UPDATE,
		null,
		null,
		true
	),
	UPDATE_FILTER(
		"UPDATE filter_table SET rule_key = ? WHERE f_key = ?",
      new SQL_ValType[] {LONG, LONG}, 
		SQL_StmtType.UPDATE,
		null,
		null,
		true
	),
   RENAME_CAT(
      "UPDATE cat_table SET name = ? WHERE cat_key = ?",
		new SQL_ValType[] {STRING, LONG},
      SQL_StmtType.UPDATE,
		new SQL_ColumnSize[] {CAT_TBL_NAME, NONE},
		null,
		true
	),
   UPDATE_CAT(
      "UPDATE cat_table SET valid = ?, f_key = ?, name = ?, cat_id = ?, parent_cat = ?, taxonomy_path = ? WHERE cat_key = ?",
		new SQL_ValType[] {BOOLEAN, LONG, STRING, INT, LONG, STRING, LONG},
      SQL_StmtType.UPDATE,
		null,
		null,
		true
	),
	UPDATE_CATS_FOR_TOPIC(
      "UPDATE cat_table SET valid = ?, f_key = -1 WHERE t_key = ?",
		new SQL_ValType[] {BOOLEAN, LONG},
      SQL_StmtType.UPDATE,
		null,
		null,
		true
	),
	UPDATE_CATS_FOR_USER(
      "UPDATE cat_table SET valid = ?, f_key = -1 WHERE u_key = ?",
		new SQL_ValType[] {BOOLEAN, LONG},
      SQL_StmtType.UPDATE,
		null,
		null,
		true
	),
		// Prepared Statement Strings for DELETEs 
	CLEAR_CAT_NEWS(
		"DELETE FROM cat_news_table WHERE c_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_NEWS_ITEM(
	   "DELETE FROM news_item_table WHERE n_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_SHARED_NEWS_ITEM_ENTRIES(
	   "DELETE FROM news_collections_table WHERE n_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_NEWS_FROM_CAT(
		"DELETE FROM cat_news_table WHERE c_key = ? AND n_key = ?",
		new SQL_ValType[] {LONG, LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_CLASSIFIED_NEWSITEM(
		"DELETE FROM cat_news_table WHERE n_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_5_NEWS_ITEMS_FROM_CAT(
		"DELETE FROM cat_news_table WHERE c_key = ? AND n_key IN (?, ?, ?, ?, ?)",
		new SQL_ValType[] {LONG, LONG, LONG, LONG, LONG, LONG},
		SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_USER_FILE(
		"DELETE FROM user_files_table WHERE u_key = ? AND file_name = ?",
		new SQL_ValType[] {LONG, STRING},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_IMPORT_DEPENDENCIES_FOR_USER(
		"DELETE FROM import_dependency_table WHERE importing_user_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_COLLECTION(
		"DELETE FROM user_collections_table WHERE coll_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_ALL_COLLECTIONS_FOR_USER(
		"DELETE FROM user_collections_table WHERE u_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_ALL_COLLECTION_ENTRIES(
		"DELETE FROM collection_entries_table WHERE coll_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_ALL_COLLECTION_ENTRIES_FOR_USER(
		"DELETE FROM collection_entries_table WHERE coll_key IN (SELECT coll_key FROM user_collections_table WHERE u_key = ?)",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_ENTRY_FROM_COLLECTION(
		"DELETE FROM collection_entries_table WHERE coll_key = ? AND entry_key = ?",
		new SQL_ValType[] {LONG, LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_SOURCE_BY_TAG(
		"DELETE FROM user_source_table WHERE u_key = ? AND coll_key = ? AND src_tag = ?",
		new SQL_ValType[] {LONG, LONG, STRING},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_SOURCE_BY_ID(
		"DELETE FROM user_source_table WHERE src_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_ALL_SOURCES_FOR_USER(
		"DELETE FROM user_source_table WHERE u_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_CATEGORY(
		"DELETE FROM cat_table WHERE cat_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_FILTER(
		"DELETE FROM filter_table WHERE f_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_ALL_FILTERS_FOR_USER(
		"DELETE FROM filter_table WHERE u_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_ALL_FILTER_TERMS_FOR_USER(
		"DELETE FROM filter_rule_term_table WHERE f_key IN (SELECT f_key FROM filter_table WHERE u_key = ?)",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_FILTER_TERMS(
		"DELETE FROM filter_rule_term_table WHERE f_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_CONCEPT_BY_ID(
		"DELETE FROM concept_table WHERE cpt_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_ALL_CONCEPTS_FOR_USER(
		"DELETE FROM concept_table WHERE u_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_CONCEPT_BY_NAME(
		"DELETE FROM concept_table WHERE u_key = ? AND coll_key = ? AND name = ?",
		new SQL_ValType[] {LONG, LONG, STRING},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_ALL_TOPIC_SOURCES_FOR_USER(
		"DELETE FROM topic_source_table WHERE t_key IN (SELECT t_key FROM topic_table WHERE u_key = ?)",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	),
	DELETE_FROM_TOPIC_SOURCE_TABLE(
		"DELETE FROM topic_source_table WHERE t_key = ?",
		new SQL_ValType[] {LONG},
      SQL_StmtType.DELETE,
		null,
		null,
		true
	);

   static Log          _log;
   static DB_Interface _db;

   public static void init(Log l, DB_Interface db)
   {
      _log = l;
		_db = db;
   }

   public final String          _stmtString;
   public final SQL_ValType[]    _argTypes;
   public final SQL_StmtType     _stmtType;
   public final SQL_ColumnSize[] _colSizes;
	public final ResultProcessor _rp;
	public final boolean         _singleRowOutput;

   SQL_Stmt(String stmt, SQL_ValType[] aTypes, SQL_StmtType type, SQL_ColumnSize[] colSizes, ResultProcessor rp, boolean singleRow)
   {
      _stmtString = stmt;
      _argTypes   = aTypes;
      _stmtType   = type;
      _colSizes   = colSizes;
		_rp         = rp;
		_singleRowOutput = singleRow;
   }

   /**
    * This method executes a prepared sql statement using arguments passed in
    * and pushes the result set through a result processor, if any.  The result
    * processor is just a cumbersome way of passing in a closure since Java
    * does not support closures yet.
    *
    * @param args   Argument array for this sql statement
	 * @returns the result of executing the query, if any 
    */
   Object execute(Object[] args)
   {
		return SQL_StmtExecutor.execute(_stmtString, _argTypes, args, _stmtType, _colSizes, _rp, _singleRowOutput);
   }
}
