package newsrack.util;

/* This class is a utility class enabling reading of stdout/stderr streams
 * of spawned subprocesses (scanner compilation, site crawlers) */
final public class ProcessReader extends java.lang.Thread {
    private String _streamName;
    private String _cmd;
    private java.io.InputStream _is;
    private java.io.OutputStream _os;

    public ProcessReader(String streamName, String cmd, java.io.InputStream is, java.io.OutputStream os) {
        _streamName = streamName;
        _cmd = cmd;
        _is = is;
        _os = os;
    }

    public void run() {
        int len;
        byte buf[] = new byte[128];
        try {
            String preamble = "----------- Output of stream <" + _streamName + "> for " + _cmd + " -----------\n";
            _os.write(preamble.getBytes());
            while (-1 != (len = _is.read(buf)))
                _os.write(buf, 0, len);
        } catch (java.io.IOException ex) {
            System.err.println(_streamName + ":" + _cmd + ": Exception " + ex);
        }
    }
}
