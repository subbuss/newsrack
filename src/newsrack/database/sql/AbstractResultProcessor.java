package newsrack.database.sql;

import java.sql.*;
import java.util.List;

public abstract class AbstractResultProcessor implements ResultProcessor
{
		// The default implementation assumes that the result processor
		// do not use instance state for processing sql query results.
		// Those processors that do use instance state are responsible
		// for overriding this method where required.
	public          ResultProcessor getNewInstance() { return this; } /* Identity operation */
	public          Object processOutput(Object o)   { return o; }		/* Identity operation */
	public          List   processOutputList(List l) { return l; }		/* Identity operation */
	public abstract Object processResultSet(ResultSet rs) throws java.sql.SQLException;
}
