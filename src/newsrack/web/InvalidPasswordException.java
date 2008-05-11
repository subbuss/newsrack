package newsrack.web;

/**
 * class <code>InvalidPasswordException</code> is thrown when
 * the specified password is incorrect for a user
 */
public class InvalidPasswordException extends java.lang.Exception
{
	private String _user;

	public InvalidPasswordException(String u) { _user = u; }

	public String toString() { return "Invalid Password for user: " + _user; }
}
