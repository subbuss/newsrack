package newsrack.filter;

public final class ConceptToken implements java.io.Serializable {
    public static final String CATCHALL = "__JUNK__";
    public static final ConceptToken CATCHALL_TOKEN = new ConceptToken(CATCHALL, "");

    public final String _text;            // Text that matched this token
    public final boolean _multiToken;    // Do multiple concepts map onto this token?
    public final String _tokens[];        // All concepts that are represented by this token

    public ConceptToken(String token) {
        _multiToken = false;
        _text = "";
        _tokens = new String[]{token};
    }

    public ConceptToken(String token, String txt) {
        _multiToken = false;
        _text = txt;
        _tokens = new String[]{token};
    }

    public ConceptToken(String[] tokens, String txt) {
//		System.out.println("Got multitoken with " + concepts.length + " concepts; zero - " + concepts[0]);
        _multiToken = true;
        _text = txt;
        _tokens = tokens;
    }

    public String toString() {
        return "<TOK:" + _tokens[0] + ">";
    }

    public boolean isMultiToken() {
        return _multiToken;
    }

    public String getToken() {
        return _tokens[0];
    }

    public String[] getTokens() {
        return _tokens;
    }
}
