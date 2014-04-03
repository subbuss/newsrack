package newsrack.web;

/**
 * class <code>InvalidPasswordException</code> is thrown when
 * the specified password is incorrect for a user
 */
public class InvalidPasswordException extends java.lang.Exception {
    private String _uid;

    public InvalidPasswordException(String u) {
        _uid = u;
    }

    public String toString() {
        return "Invalid Password for user: " + _uid;
    }
}
