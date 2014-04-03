package newsrack.filter;

/**
 * This class represents the various privacy modes.  This class can potentially
 * be used in multiple places in the web app.
 */

public enum Privacy {
    PUBLIC, PRIVATE;

    static final private Privacy[] pvals;

    static {
        pvals = values();
    }

    static public Privacy getValue(int index) {
        return pvals[index];
    }
};
