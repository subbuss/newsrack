package newsrack.database.sql;

import newsrack.database.NewsIndex;
import newsrack.archiver.Feed;
import java.sql.Date;

public class SQL_NewsIndex extends NewsIndex
{
	private Long _niKey;
	private Long _feedKey;
	private Date _createdAt;

	public SQL_NewsIndex(Long key) { _niKey = key; }
	public SQL_NewsIndex(Long key, Date t) { _niKey = key; _createdAt = t; }
	public SQL_NewsIndex(Long key, Long feedKey, Date d) { _niKey = key; _feedKey = feedKey; _createdAt = d; }

	public Feed getFeed()         { return SQL_DB._sqldb.getFeed(_feedKey); }
	public Date getCreationTime() { return _createdAt; }

	public Long   getKey()        { return _niKey; }
	public Long   getFeedKey()    { return _feedKey; }
}
