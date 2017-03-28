package newsrack.util;

import newsrack.NewsRack;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Hashtable;
import java.util.zip.GZIPInputStream;
import java.util.zip.Inflater;
import java.util.zip.InflaterInputStream;

/**
 * The class <code>IOUtils</code> provides file/IO functionality
 * which does not go anywhere else in the system.
 */
public final class IOUtils {
    /* Number of tags stored in the _eTags and _lastModifiedTags
     * tables.  Once the size hits this number, the table is purged. */
    private static final int MAX_STORED_TAGS = 2048;
    private static final int BUFFER_SIZE = 1024;    //1 kb
    private static Log _log = LogFactory.getLog(IOUtils.class);
    private static Hashtable _eTags = new Hashtable();
    private static Hashtable _lastModifiedTags = new Hashtable();

    private static void INFO(String msg) {
        if (_log.isInfoEnabled()) _log.info(msg);
    }

    public static void printStackTrace(Throwable e, Log log) {
        StringWriter sw = new StringWriter();
        e.printStackTrace(new PrintWriter(sw));
        log.info("Stack Trace: " + sw.toString());
    }

    /**
     * This method copies the contents of an input stream to the output stream
     *
     * @param in  The input stream to be copied.
     * @param out The output stream to copy to.
     */
    public static void copyInputToOutput(InputStream in, OutputStream out, boolean closeStreams) throws java.io.IOException {
        byte[] buf = new byte[BUFFER_SIZE];
        BufferedInputStream bis = new BufferedInputStream(in);
        BufferedOutputStream bos = new BufferedOutputStream(out);

        while (true) {
            int n = bis.read(buf, 0, BUFFER_SIZE);
            if (n == -1)
                break;
            bos.write(buf, 0, n);
        }
        bos.flush();

        if (closeStreams) {
            bis.close();
            bos.close();
        }
    }

    /**
     * This method copies the contents of an input stream to a file
     * on the local file system.
     *
     * @param input         The input stream to be copied.
     * @param localCopyName The name of the local file into which the stream is copied.
     */
    public static void copyStreamToLocalFile(InputStream input, String localCopyName) throws java.io.IOException {
        // It is the caller's responsibility to close the input stream!
        FileOutputStream fos = null;
        try {
            fos = new FileOutputStream(localCopyName);
            copyInputToOutput(input, fos, false);
        } finally {
            if (fos != null)
                fos.close();
        }
    }

    /**
     * Create a directory if it doesn't exist
     *
     * @param dname Name of the directory to be created
     */
    public static synchronized void createDir(String dname) {
        File d = new File(dname);
        if (!d.exists())
            d.mkdirs();    // Create any necessary non-existent parent directories!
    }

    /**
     * This method moves a file from one location to another
     *
     * @param oldLocn old location of the file
     * @param newLocn new location of the file
     */
    public static synchronized void moveFile(String oldLocn, String newLocn) {
        (new File(oldLocn)).renameTo(new File(newLocn));
    }

    private static InputStream getInputStream(URL u) throws java.io.IOException {
        // Some of this code was obtained from http://www.oreillynet.com/pub/wlg/5216
        //   Optimizing HTTP downloads in Java through conditional GET and compressed streams
        //   - Diego Doval
        // The code was modified to suit our purposes

        HttpURLConnection connection = null;
        InputStream inStream = null;

        try {
            connection = (HttpURLConnection) u.openConnection();
            // add parameters to the connection
            connection.setFollowRedirects(true);
            // allow both GZip and Deflate (ZLib) encodings
            connection.setRequestProperty("Accept-Encoding", "gzip, deflate");
            String ua = NewsRack.getProperty("useragent.string");
            if (ua == null) ua = "NewsRack/1.0 (http://newsrack.in)";
            connection.addRequestProperty("User-Agent", ua);

            String eTag = (String) _eTags.get(u);
            if (eTag != null) {
                connection.addRequestProperty("If-None-Match", eTag);
            }

            // Add the last modified tag
            String lastModifiedTag = (String) _lastModifiedTags.get(u);
            if (lastModifiedTag != null) {
                connection.addRequestProperty("If-Modified-Since", lastModifiedTag);
            }

            // establish connection, get response headers
            connection.connect();

            // obtain the encoding returned by the server
            String encoding = connection.getContentEncoding();

            // The Content-Type can be used later to determine the nature of the content regardless of compression
            // String contentType = connection.getContentType();

            // if it returns Not modified then we already have the content, return
            if (connection.getResponseCode() == HttpURLConnection.HTTP_NOT_MODIFIED) {
                INFO(u + " not modified since last download");
                return null;
            }

            // Purge the tag tables if they are bigger than a particular size
            if (_eTags.size() == MAX_STORED_TAGS) {
                _eTags = new Hashtable();
                _lastModifiedTags = new Hashtable();
            }

            // get the last modified & etag and store them for the next check
            eTag = connection.getHeaderField("ETag");
            if (eTag != null) {
                _eTags.put(u, eTag);
            } else {
                INFO("Null etag for " + u);
            }
            lastModifiedTag = connection.getHeaderField("Last-Modified");
            if (lastModifiedTag != null) {
                _lastModifiedTags.put(u, lastModifiedTag);
            } else {
                INFO("Null lastModifiedTag for " + u);
            }

            // create the appropriate stream wrapper based on the encoding type
            if (encoding != null && encoding.equalsIgnoreCase("gzip")) {
                inStream = new GZIPInputStream(connection.getInputStream());
            } else if (encoding != null && encoding.equalsIgnoreCase("deflate")) {
                inStream = new InflaterInputStream(connection.getInputStream(), new Inflater(true));
            } else {
                inStream = connection.getInputStream();
            }

            // Slurp the data into a byte array and return the byte array
            // We are doing this so that we can close the http connection
            // before returning from here!
            ByteArrayOutputStream outStream = new ByteArrayOutputStream();
            copyInputToOutput(inStream, outStream, false);
            return new ByteArrayInputStream(outStream.toByteArray());
        } finally {
            if (inStream != null) inStream.close();
            if (connection != null) connection.disconnect();
        }
    }

    /**
     * Returns an input stream for a URL -- a certain number of tries
     * are made to open an input stream within a fixed time duration.
     * Beyond that, a null stream is returned.  The timeout period is
     * set at system initialization time -- default 5 seconds.
     *
     * @param u          URL which needs to be opened
     * @param numRetries number of times to try opening the input stream
     *                   in the face of socket time-outs
     */
    public static InputStream getURLInputStream(URL u, int numRetries) throws IOException {
        int numTries = 0;
        while (true) {
            try {
                return getInputStream(u);
            }
                /* Catch timeouts and other exceptions and keep trying */ catch (IOException ste) {
                numTries++;
                if (numTries >= numRetries)
                    throw ste;
            } catch (java.lang.ClassCastException e) {
                java.net.URLConnection connection = u.openConnection();
                connection.connect();
                return connection.getInputStream();
            }
        }
    }

    /**
     * Returns a print writer that outputs data in UTF-8.  The data
     * to be written to the file need not all be English -- this
     * makes it important for the data to be output in UTF-8 rather
     * than use the default platform encoding
     *
     * @param file File which needs to be written to
     */
    public static PrintWriter getUTF8Writer(String file) throws java.io.IOException {
        return getUTF8Writer(new FileOutputStream(file));
    }

    /**
     * Returns a print writer that outputs data in UTF-8.  The data
     * to be written to the stream need not all be English -- this
     * makes it important for the data to be output in UTF-8 rather
     * than use the default platform encoding
     *
     * @param os OutputStream to which data will be written
     */
    public static PrintWriter getUTF8Writer(OutputStream os) throws java.io.IOException {
        return new PrintWriter(new BufferedWriter(new OutputStreamWriter(os, "UTF-8")));
    }

    /**
     * Returns a buffered reader that reads data from UTF-8 encoded files.
     * The data to be read from the file need not all be English -- this
     * makes it important for the data to be read as UTF-8 rather than read
     * it using the default platform encoding
     *
     * @param file File which needs to be read
     */
    public static Reader getUTF8Reader(String file) throws java.io.IOException {
        return getUTF8Reader(new FileInputStream(file));
    }

    /**
     * Returns a buffered reader that reads data from UTF-8 encoded streams.
     *
     * @param is InputStream from which data will be read
     */
    public static Reader getUTF8Reader(InputStream is) throws java.io.IOException {
        return new BufferedReader(new InputStreamReader(is, "UTF-8"));
    }

    /**
     * Returns a buffered reader that reads data from UTF-8 encoded streams.
     * A certain number of tries are made to open an input stream within a
     * fixed time duration. Beyond that, a null stream is returned.
     * The timeout period is set at system initialization time -- default 5 seconds.
     *
     * @param u          URL which needs to be opened
     * @param numRetries number of times to try opening the input stream
     *                   in the face of socket time-outs
     */
    public static Reader getUTF8Reader(URL u, int numRetries) throws IOException {
        return getUTF8Reader(getURLInputStream(u, numRetries));
    }

    /**
     * Reads the contents of a file into a string!
     *
     * @param fileName File object for the file
     */
    public static String readFile(File f) throws IOException {
        StringBuffer sb = new StringBuffer(1024);
        BufferedReader reader = new BufferedReader(new FileReader(f));

        char[] chars = new char[1024];
        while (reader.read(chars) > -1) {
            sb.append(String.valueOf(chars));
        }

        reader.close();

        return sb.toString();
    }

    /**
     * Writes the content of an entire string into a file
     */
    public static void writeFile(File f, String contents) throws IOException {
        FileWriter fw = new FileWriter(f);
        fw.write(contents);
        fw.close();
    }
}
