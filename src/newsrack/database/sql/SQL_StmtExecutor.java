package newsrack.database.sql;

import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;

import java.sql.*;
import java.sql.Connection;

import snaq.db.ConnectionPool;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import newsrack.database.DB_Interface;

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

abstract class AbstractResultProcessor implements ResultProcessor
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

class GetStringResultProcessor extends AbstractResultProcessor
{
	public Object processResultSet(ResultSet rs) throws java.sql.SQLException { return rs.getString(1); }
}

class GetIntResultProcessor extends AbstractResultProcessor
{
	public Object processResultSet(ResultSet rs) throws java.sql.SQLException { return new Integer(rs.getInt(1)); }
}

class GetLongResultProcessor extends AbstractResultProcessor
{
	public Object processResultSet(ResultSet rs) throws java.sql.SQLException 
	{ 
		long retval = rs.getLong(1);
		if (SQL_StmtExecutor._log.isDebugEnabled()) SQL_Stmt._log.debug("Long Val Result processor: Returning " + retval);
		return new Long(retval); 
	}
}

public class SQL_StmtExecutor
{
           static Log            _log;
           static DB_Interface   _db;
   private static ConnectionPool _dbPool;
   private static boolean        _adminAlerted;
	private static int            _stmtExecutionCount;

   public static void init(ConnectionPool p, Log l, DB_Interface db)
   {
      _dbPool = p;
      _log    = l;
      _adminAlerted = false;
		_db = db;
   }

	public static void printStats(Log l)
	{
		l.info("Total SQL executions: " + _stmtExecutionCount);
		for (SQL_StmtType t: SQL_StmtType.values()) {
			l.info("Executions of SQL stmt type " + t + ": " + t._executionCount);
		}
	}

	static void closeConnection(Connection c)
	{
		try {
			if (c != null) {
				c.close();
			}
		}
		catch (Exception e) {
			_log.error("Exception closing SQL connection: " + e);
			e.printStackTrace();
		}
	}

	static void closeStatement(Statement s)
	{
		try {
			if (s != null) {
				s.close();
			}
		}
		catch (Exception e) {
			_log.error("Exception closing SQL statment: " + e);
			e.printStackTrace();
		}
	}

	static void closeResultSet(ResultSet rs)
	{
		try {
			if (rs != null) {
				rs.close();
			}
		}
		catch (Exception e) {
			_log.error("Exception closing result set: " + e);
			e.printStackTrace();
		}
	}

	private static Object processResults(ResultProcessor rp, Connection c, PreparedStatement stmt, ResultSet rs, boolean singleRowOutput) throws java.sql.SQLException
	{
			// Fetch a new instance for every query!
			//
			// Otherwise, we will have conflicts for those processors
			// that use object state during result processing, and we don't
			// want to synchronize on these objects!!
		rp = rp.getNewInstance();

		if (singleRowOutput) {
			Object retVal = null;
			if (rs.next()) {
				retVal = rp.processResultSet(rs);
				if (rs.next()) // Since this is supposed to be a single row result there cannot be multiple rows!
					throw new SQL_UniquenessConstraintViolationException("Multiple results found!");
			}

				// Close all db resources before doing further post-processing
				// This prevents deadlock!  Otherwise, processOutput might stall
				// waiting for db resources, while another thread might also have
				// stalled waiting for db resources!
			closeResultSet(rs);
			closeStatement(stmt);
			closeConnection(c);

				// Do any necessary post-processing of the object
			return rp.processOutput(retVal);
		}
		else {
			List l = new ArrayList();
			while (rs.next()) {
				Object o = rp.processResultSet(rs);
				if (o != null)
					l.add(o);
			}

				// Close all db resources before doing further post-processing
				// This prevents deadlock!
			closeResultSet(rs);
			closeStatement(stmt);
			closeConnection(c);

				// Do any necessary post-processing of the list
			return rp.processOutputList(l);
		}
	}

   /**
    * This method executes a prepared sql statement using arguments passe in
    * and pushes the result set thorough a result processor, if any.  The result
    * processor is just a cumbersome way of passing in a closure since Java
    * does not support closures yet.
    *
    * @param args   Argument array for this sql statement
	 * @returns the result of executing the query, if any 
    */
   public static Object execute(String stmtString, SQL_ValType[] argTypes, Object[] args, SQL_StmtType stmtType, SQL_ColumnSize[] colSizes, ResultProcessor rp, boolean singleRowOutput)
   {
      int n = -1;
		Connection c = null;
		ResultSet rs = null;
		PreparedStatement stmt = null;
		Object retVal = null;

		try {
         if (args.length != argTypes.length)
            throw new SQL_ArgumentMismatchException("Mismatch in number of arguments(" + args.length + ") and argument types(" + argTypes.length + ")");

			c = _dbPool.getConnection();
			if (c == null)
				_log.error("Got a null DB connection!");

			stmt = c.prepareStatement(stmtString, Statement.RETURN_GENERATED_KEYS);
         for (int i = 0; i < args.length; i++) {
            argTypes[i].setStmtArg(stmt, i+1, args[i]);
/**
               // Check for column violation constraint
            if (   (colSizes != null) 
                && (argTypes[i] == STRING) 
                && (colSizes[i] != NONE)
                && (((String)args[i]).length() > colSizes[i]._size)
               )
            {
               throw new SQL_ColumnSizeException(i, (String)args[i], colSizes[i]._size);
            }
**/
         }

			_stmtExecutionCount++;
			stmtType._executionCount++;
         switch (stmtType) {
            case QUERY  :
               rs = stmt.executeQuery();
					if (_log.isDebugEnabled()) _log.debug("Query statement " + stmt + " completed without exceptions!");
					if (rp == null) {
						retVal = null;
					}
					else {
						retVal = processResults(rp, c, stmt, rs, singleRowOutput);
							// processResultSet should have closed the connection, stmt, and the result set
							// so, set them to null
						c    = null;
						stmt = null;
						rs   = null;
					}
					return retVal;

            case INSERT : 
               n = stmt.executeUpdate();
					if (_log.isDebugEnabled()) _log.debug("Insert statement " + stmt + " completed without exceptions!");
					if (n == 0)
						_log.error("Insert statement " + stmt + " returned 0 rows!");

					if (rp == null) {
						retVal = null;
					}
					else {
						rs = stmt.getGeneratedKeys();
						retVal = processResults(rp, c, stmt, rs, singleRowOutput);
							// processResultSet should have closed the connection, stmt, and the result set
							// so, set them to null
						c    = null;
						stmt = null;
						rs   = null;
					}
					return retVal;

            case UPDATE :
					retVal = new Integer(stmt.executeUpdate());
					if (_log.isDebugEnabled()) _log.debug("Update statement " + stmt + " completed without exceptions!");
					return retVal;

            case DELETE :
					retVal = new Integer(stmt.executeUpdate());
					if (_log.isDebugEnabled()) _log.debug("Delete statement " + stmt + " completed without exceptions!");
					return retVal;

				default:
					_log.error("Unknown statement type: " + stmtType + " for query: " + stmtString);
					return null;
         }
		}
      catch (SQL_ArgumentMismatchException e) {
			_log.error("Exception while executing stmt " + stmt, e);
         throw e;
      }
      catch (SQL_ColumnSizeException e) {
			_log.error("Exception while executing stmt " + stmt, e);
         throw e;
      }
		catch (Exception e) {
         // e can be a java.net.SocketException but no one in the body is throwing this exception
         // so, I cannot write a catch clause ... I have do the typecheck as below ...
         if ((e instanceof java.net.SocketException) && !_adminAlerted) {
            newsrack.util.MailUtils.alertAdmin("database server returning java.net.SocketException! Can you check if db server needs restarting?" + e);
            _adminAlerted = true;
         }
			_log.error("Exception while executing stmt " + stmt, e);
			return null;
		}
      finally {
			closeResultSet(rs);
			closeStatement(stmt);
			closeConnection(c);
      }
   }
}
