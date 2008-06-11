package newsrack.database.sql;

import newsrack.database.NewsIndex;
import newsrack.archiver.Feed;
import java.sql.Timestamp;

class SQL_NewsIndex extends NewsIndex
{
	private Long      _niKey;
	private String    _dateString;
	private Long      _feedKey;
	private Timestamp _createdAt;

	public SQL_NewsIndex(Long key) { _niKey = key; }
	public SQL_NewsIndex(Long key, String dateString, Timestamp t) { _niKey = key; _dateString = dateString; _createdAt = t; }
	public SQL_NewsIndex(Long key, Long feedKey, String dateString) { _niKey = key; _feedKey = feedKey; _dateString = dateString; }

	public Feed      getFeed()         { return SQL_DB._sqldb.getFeed(_feedKey); }
	public Timestamp getCreationTime() { return _createdAt; }

	public Long   getKey()        { return _niKey; }
	public Long   getFeedKey()    { return _feedKey; }
	public String getDateString() { return _dateString; }
}
