package newsrack.database.sql;

import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;

public enum SQL_ValType {
    STRING {
        void setStmtArg(PreparedStatement stmt, int argPos, Object argVal) throws SQLException {
            if (argVal == null)
                stmt.setNull(argPos, Types.VARCHAR);
            else
                stmt.setString(argPos, (String) argVal);
        }
    },
    INT {
        void setStmtArg(PreparedStatement stmt, int argPos, Object argVal) throws SQLException {
            if (argVal == null)
                stmt.setNull(argPos, Types.INTEGER);
            else
                stmt.setInt(argPos, (Integer) argVal);
        }
    },
    SHORT {
        void setStmtArg(PreparedStatement stmt, int argPos, Object argVal) throws SQLException {
            if (argVal == null)
                stmt.setNull(argPos, Types.SMALLINT);
            else
                stmt.setShort(argPos, (Short) argVal);
        }
    },
    LONG {
        void setStmtArg(PreparedStatement stmt, int argPos, Object argVal) throws SQLException {
            if (argVal == null)
                stmt.setNull(argPos, Types.BIGINT);
            else
                stmt.setLong(argPos, (Long) argVal);
        }
    },
    FLOAT {
        void setStmtArg(PreparedStatement stmt, int argPos, Object argVal) throws SQLException {
            if (argVal == null)
                stmt.setNull(argPos, Types.FLOAT);
            else
                stmt.setFloat(argPos, (Float) argVal);
        }
    },
    DOUBLE {
        void setStmtArg(PreparedStatement stmt, int argPos, Object argVal) throws SQLException {
            if (argVal == null)
                stmt.setNull(argPos, Types.DOUBLE);
            else
                stmt.setDouble(argPos, (Double) argVal);
        }
    },
    BOOLEAN {
        void setStmtArg(PreparedStatement stmt, int argPos, Object argVal) throws SQLException {
            if (argVal == null)
                stmt.setNull(argPos, Types.BOOLEAN);
            else
                stmt.setBoolean(argPos, (Boolean) argVal);
        }
    },
    DATE {
        void setStmtArg(PreparedStatement stmt, int argPos, Object argVal) throws SQLException {
            if (argVal == null)
                stmt.setNull(argPos, Types.DATE);
            else
                stmt.setDate(argPos, (java.sql.Date) argVal);
        }
    },
    TIMESTAMP {
        void setStmtArg(PreparedStatement stmt, int argPos, Object argVal) throws SQLException {
            if (argVal == null)
                stmt.setNull(argPos, Types.TIMESTAMP);
            else
                stmt.setTimestamp(argPos, (Timestamp) argVal);
        }
    };

    abstract void setStmtArg(PreparedStatement stmt, int argPos, Object argVal) throws SQLException;
};
