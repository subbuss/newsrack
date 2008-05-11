package newsrack.database.sql;

enum SQL_StmtType
{
	QUERY("Query"), UPDATE("Update"), INSERT("Insert"), DELETE("Delete");

	private   String _name;
	protected int    _executionCount = 0;

	SQL_StmtType(String name) { _name = name; }

	public String toString() { return _name; }
};
