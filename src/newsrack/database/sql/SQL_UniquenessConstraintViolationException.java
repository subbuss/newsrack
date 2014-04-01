package newsrack.database.sql;

public class SQL_UniquenessConstraintViolationException extends RuntimeException {
    final public Object firstResult;

    public SQL_UniquenessConstraintViolationException(Object res, String s) {
        super(s);
        firstResult = res;
    }
}
