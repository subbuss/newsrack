package newsrack.database; 

import java.io.OutputStream;
import java.util.Date;

/**
 * This abstract class represents a news index in the back end -- it can either be a file handle
 * to an XML file, or a key to a row in a database.
 */
public abstract class NewsIndex 
{
	/**
	 * Returns the time this news index was last updated!
	 * An implementation can choose not to provide this functionality
	 * and return null instead!  But, if the implementation returns a
	 * non-null value, it will be assumed that the time returned is a reliable
	 * estimate of the time of last update of this news index.
	 */
	abstract public Date getLastUpdateTime();
}
