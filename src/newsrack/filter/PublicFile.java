package newsrack.filter;

/**
 * class <code>PublicFile</code> is a "bean" class for holding
 * information about publicly accessible profile files -- the
 * class records information about the owner of the file, and the
 * name of the file.
 *
 * @author Subramanya Sastry
 * @version 1.0 22/09/04
 */
public class PublicFile implements java.io.Serializable
{
	private final String _fileName;
	private final String _fileOwner;

	public PublicFile(final String f, final String o) { _fileOwner = o; _fileName = f; } 

	public String getFileName()  { return _fileName; }
	public String getFileOwner() { return _fileOwner; }

	/**
	 * Checks if the object <code>o</code> is the same public
	 * file as <code>this</code>
	 */
	public boolean equals(final Object o) 
	{
		if (!(o instanceof PublicFile))
			return false;

		final PublicFile pf = (PublicFile)o;
		return (pf._fileName.equals(_fileName) && pf._fileOwner.equals(_fileOwner));
	}
}
