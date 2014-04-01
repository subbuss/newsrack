package newsrack.database.sql;

import java.sql.ResultSet;
import java.util.List;

// Represents an interface for processing SQL query results
interface ResultProcessor {
    // Processors that use object state during result processing
    // might return clones!  If we don't return cloned objects, we
    // will have data conflicts since the result processing code
    // does not synchronize on these objects.
    public ResultProcessor getNewInstance();

    // IMPORTANT: processResultSet methods *should complete* WITHOUT
    // attempting to acquire additional db resources!  Otherwise, we
    // will deadlock.  I might stall waiting for db resources within
    // processResultSet, while another thread might also have stalled
    // in another processResultSet waiting for db resources!
    public Object processResultSet(ResultSet rs) throws java.sql.SQLException;

    public Object processOutput(Object o);

    public List processOutputList(List l);
}
