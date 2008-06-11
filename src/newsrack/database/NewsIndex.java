package newsrack.database; 

import java.io.OutputStream;
import java.sql.Timestamp;
import newsrack.archiver.Feed;

/**
 * This abstract class represents a news index in the back end -- it can either be a file handle
 * to an XML file, or a key to a row in a database.
 */
public abstract class NewsIndex implements java.io.Serializable
{
	abstract public Feed getFeed();
	abstract public Timestamp getCreationTime();
}
