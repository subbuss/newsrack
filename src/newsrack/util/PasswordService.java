package newsrack.util;

import newsrack.NewsRack;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 * Adapted from http://www.devbistro.com/articles/Java/Password-Encryption *
 */

public final class PasswordService {
    private static final int RESET_KEY_VALIDITY = 30;  // 30 minute validity of password reset keys

    // Logging output for this class
    private static Log _log = LogFactory.getLog(PasswordService.class);

    // How long is a password reset key valid (in minutes)?
    private static int _resetKeyValidityTime = 0;

    private static PasswordService _instance;
    private static Map<String, Tuple> _passwordResetKeys;

    private PasswordService() {
    }

    public static void init() {
        _instance = new PasswordService();
        _passwordResetKeys = new HashMap<String, Tuple>();

        String rkvString = NewsRack.getProperty("password.resetkey.timevalidity");
        try {
            if (rkvString != null)
                _resetKeyValidityTime = Integer.parseInt(rkvString);
            else
                _resetKeyValidityTime = RESET_KEY_VALIDITY;
        } catch (Exception e) {
            _log.error("Error parsing password.resetkey.timevalidity string " + rkvString);
            _resetKeyValidityTime = RESET_KEY_VALIDITY;
        }
    }

    public static synchronized PasswordService getInstance() {
        if (_instance == null)
            init();
        return _instance;
    }

    public static String encrypt(String plaintext) {
        try {
            MessageDigest md5 = MessageDigest.getInstance("MD5");
            // FIXME: synchronization required?
            synchronized (md5) {
                md5.update(plaintext.getBytes("UTF-8"));
                byte raw[] = md5.digest();
                return new String(java.util.Base64.getMimeEncoder().encode(raw),
                    java.nio.charset.StandardCharsets.UTF_8);
            }
        } catch (Exception e) {
            _log.error("PasswordService", e);
            throw new RuntimeException(e);
        }
    }

    public static String getRandomKey() {
        Random r1 = new Random();
        String t1 = Long.toString(Math.abs(r1.nextLong()), 36);
        Random r2 = new Random();
        String t2 = Long.toString(Math.abs(r2.nextLong()), 36);

        return t1 + t2;
    }

    public static String getPasswordResetKey(String uid) {
        String pwResetKey = getRandomKey();
        _passwordResetKeys.put(uid, new Tuple(pwResetKey, new Date()));
        return pwResetKey;
    }

    public static boolean isAValidPasswordResetKey(String uid, String resetKey) {
        Tuple t = _passwordResetKeys.get(uid);
        if ((t == null) || !resetKey.equals(t._a)) {
            _log.error("Invalid password reset key " + resetKey + " for " + uid);
            return false;
        }

        long timeDiff = (new Date()).getTime() - ((Date) t._b).getTime();
        if (timeDiff > (1000 * 60 * _resetKeyValidityTime)) { // resetKeyValidityTime minute validity
            _log.error("Expired password reset key for " + uid + ". Generated " + timeDiff / 1000 + " seconds back.  Max validity is for " + _resetKeyValidityTime + " minutes!");
            return false;
        }

        return true;
    }

    public static void invalidatePasswordResetKey(String uid) {
        if (uid != null)
            _passwordResetKeys.remove(uid);
    }

    public static void main(String[] args) throws Exception {
        System.out.println("Got key " + getRandomKey());
    }
}
