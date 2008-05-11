package newsrack.database.sql;

public class SQL_UniquenessConstraintViolationException extends RuntimeException
{
   public SQL_UniquenessConstraintViolationException(String s) { super(s); }
}
