package newsrack.util;

import newsrack.NewsRack;
import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

/**
 * This class implements a newsrack-specific entity resolver,
 * specifically for resolving DTD references.
 *
 * @author Subramanya Sastry
 */
public class NewsRackEntityResolver implements EntityResolver {
    /**
     * This method returns a newsrack DTD being referenced by the XML
     * profile files.
     *
     * @param dtd Name of the dtd being requested.
     * @return Returns an input stream for reading the dtd, if the dtd
     * exists and is accessible.  Else throws an IO exception
     */
    public InputStream getDTD(String dtd) throws java.io.IOException {
        if (dtd.indexOf(File.separator) != -1)
            throw new java.io.IOException("Cannot have / in dtd name.  Access denied");
        String DTD_DIR = NewsRack.getWebappPath() + File.separator + NewsRack.getProperty("dtdDir");
        String dtdPath = DTD_DIR + File.separator + dtd;
        System.out.println("Returning IS for " + dtdPath);
        return new FileInputStream(dtdPath);
    }

    public InputSource resolveEntity(String publicId, String systemId) {
        if (systemId.startsWith("newsrack://dtds/")) {
            int n = "newsrack://dtds/".length();
            String dtd = systemId.substring(n);
//			System.out.println("Requesting: pub - " + publicId + ", sys - " + systemId);
            try {
                return new InputSource(getDTD(dtd));
/**
 DB_Interface db = NewsRack.getDBInterface();
 if (db == null) {
 String dtdPath = "/usr/local/resin/webapps/newsrack/dtds/" + dtd;
 System.out.println("Returning FIS for " + dtdPath);
 return new InputSource(new FileInputStream(dtdPath));
 }
 else {
 InputStream is = getDTD(dtd);
 return new InputSource(is);
 }
 **/
            } catch (Exception e) {
                System.out.println("EXCEPTION: " + e);
                return null;
            }
        } else { // use the default behaviour
            return null;
        }
    }
}
