package newsrack.filter;

import java.io.Reader;
import java.net.URL;

import newsrack.user.User;
import newsrack.util.IOUtils;
import newsrack.util.ParseUtils;

/**
 * The class <code>UserFile</code> represents a file in the user's profile
 * @author  Subramanya Sastry
 * @version 1.0 November 12, 2006
 */

public class UserFile
{
	public final User   _user;		// The user in whose space this file exists
	public final String _name;		// Name of the file

	private boolean _isUrl          = false;
	private boolean _isNewsrackFile = false;
	private boolean _isUsersFile    = false;
	private boolean _isLocalFile    = false;

	/** This constructor creates an UserFile object given a file name
	  * and the user for whom the file has been created.
	  *
     * @param u        User in whose space this file exists
     * @param name     Name of the file
     */
	public UserFile(User u, String name) 
	{ 
		_user = u;
		_name = name;
		if (_name.length() == 0)
			ParseUtils.parseError(u, "Empty file name!");
		else
			parseName();
	}

	/** This constructor creates an UserFile object given a file name.
	  *
     * @param name     Name of the file
     */
	public UserFile(String name) 
	{
		_user = null;
		_name = name;
		if (_name.length() == 0)
			ParseUtils.parseError((UserFile)null, "Empty file name!");
		else
			parseName();
	}

	private void parseName()
	{
		if (_name.startsWith("http://")) {
			_isUrl = true;
		}
		else if (_user != null) {
			_isUsersFile = true;
		}
		else {
			_isLocalFile = true;
		}
	}

	/** This method provides a character to read the XML file.
	  * The file in question could be available locally, in a user's
	  * space, or available on the web.
	  *
	  * @return a characte reader to read this file
     */
	public Reader getFileReader() throws java.io.IOException
	{
		if (_isUsersFile) {
			return _user.getFileReader(_name);
		}
		else if (_isNewsrackFile) {
				/* @todo: Consider providing a "global/library/common" file-space
				 * where several files are made available independent of users.
				 * Also, provide users the ability to move their files to the
				 * global space.  Note that public files might get deleted once
				 * a user deletes his account. */

				/* A newsrack file URI will be of the form: newsrack://user/file
				 * Extract the user name and file name from the file URI */
			int    i = "newsrack://".length();
			int    j = _name.lastIndexOf('/');
			String u = _name.substring(i, j);
			String f = _name.substring(j+1);
			return _user.getFileReader(u, f);
		}
		else if (_isUrl) {
			return IOUtils.getUTF8Reader((new URL(_name)).openStream());
		}
		else { /* (_isLocalFile) */
			return IOUtils.getUTF8Reader(_name);
		}
	}
}
