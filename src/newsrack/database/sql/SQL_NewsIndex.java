package newsrack.database.sql;

import newsrack.database.NewsIndex;
import java.util.Date;
import java.io.OutputStream;

class SQL_NewsIndex extends NewsIndex
{
	private Long   _niKey;
	private String _dateString;
	private Long   _feedKey;

	public SQL_NewsIndex(Long key) { _niKey = key; }
	public SQL_NewsIndex(Long key, String dateString) { _niKey = key; _dateString = dateString; }
	public SQL_NewsIndex(Long key, Long feedKey, String dateString) { _niKey = key; _feedKey = feedKey; _dateString = dateString; }

	public Long   getKey() { return _niKey; }
	public Long   getFeedKey() { return _feedKey; }
	public String getDateString() { return _dateString; }
	public Date   getLastUpdateTime() { return null; }
}
