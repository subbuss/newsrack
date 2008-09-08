package newsrack.database.sql;

import java.sql.*;
import java.util.List;

// Represents an interface for processing SQL query results
interface ResultProcessor
{
		// Processors that use object state during result processing
		// might return clones!  Otherwise, we will have conflicts
		// for those processors since the result processing code do not
		// synchronize on these objects
	public ResultProcessor getNewInstance();

		// IMPORTANT: processResultSet methods *should complete* WITHOUT
		// attempting to acquire additional db resources!  Otherwise, we
		// will deadlock.  I might stall waiting for db resources within
		// processResultSet, while another thread might also have stalled 
		// in another processResultSet waiting for db resources!
	public Object processResultSet(ResultSet rs) throws java.sql.SQLException;
	public Object processOutput(Object o);
	public List   processOutputList(List l);
}
