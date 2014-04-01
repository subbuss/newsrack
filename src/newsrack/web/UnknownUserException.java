package newsrack.web;

/**
 * class <code>UnknownUserException</code> is thrown when
 * the user name is invalid.
 */
public class UnknownUserException extends java.lang.Exception {
    private String _uid;

    public UnknownUserException(String u) {
        _uid = u;
    }

    public String toString() {
        return "Unknown User: " + _uid;
    }
}
