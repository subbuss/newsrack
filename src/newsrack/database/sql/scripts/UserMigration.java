package newsrack.database.sql.scripts;

import newsrack.NewsRack;
import newsrack.user.User;
import newsrack.filter.Issue;
import newsrack.archiver.Feed;
import newsrack.archiver.Source;
import newsrack.database.sql.SQL_ValType;
import newsrack.database.sql.SQL_StmtExecutor;
import java.util.List;
import java.util.ArrayList;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class UserMigration
{
   private static Log _log = LogFactory.getLog((new UserMigration()).getClass());

	public static void updateArtCounts()
	{
      List<Issue> issues = User.getAllValidatedIssues();
		for (Issue i: issues) {
			i.storeNewsToArchive();
		}
	}

	public static void migrateUser(String uid)
	{
		System.out.println("--- Migrating user .. " + uid);
		try {
			User u = User.getUser(uid);
			u.validateIssues(true);
			for (Source s: u.getSources()) {
				Feed f = s.getFeed();
				try {
					SQL_StmtExecutor.update("UPDATE feeds SET feed_name = ? WHERE feed_key = ? AND feed_name=''",
													new SQL_ValType[] {SQL_ValType.STRING, SQL_ValType.LONG},
													new Object[] {s.getName(), f.getKey()});
				}
				catch (Exception e) {
					_log.error("Error setting feed name", e);
				}
			}
		}
		catch (Exception e) {
			_log.error("ERROR VALIDATING user: " + uid, e);
		}
	}

	public static List<User> getAllValidatedUsers()
	{
		List<User> allUsers = User.getAllUsers();
		List<User> validatedUsers = new ArrayList<User>();
		for (User u: allUsers) {
			if (u.isValidated())
				validatedUsers.add(u);
		}

		return validatedUsers;
	}

	public static void updateFeedNames()
	{
		List<User> validatedUsers = getAllValidatedUsers();
		validatedUsers.add(0, User.getUser("demo"));
		validatedUsers.add(0, User.getUser("subbu"));
		for (User u: validatedUsers) {
			System.out.println("Got uid: " + u.getUid());
			for (Source s: u.getSources()) {
				Feed f = s.getFeed();
				try {
					SQL_StmtExecutor.update("UPDATE feeds SET feed_name = ? WHERE feed_key = ? AND feed_name=''",
													new SQL_ValType[] {SQL_ValType.STRING, SQL_ValType.LONG},
													new Object[] {s.getName(), f.getKey()});
				}
				catch (Exception e) {
					_log.error("Error setting feed name", e);
				}
			}
		}
	}

	public static void migrateAllV1UsersToV2()
	{
		List<User> validatedUsers = getAllValidatedUsers();
		System.out.println("--- Invalidating first ---");
		for (User u: validatedUsers) {
			System.out.println("UID: " + u.getUid());
			try { u.invalidateAllIssues(); } catch (Exception e) { _log.error("ERROR INVALIDATING:", e); }
		}

			// Validating these 3 first in this order ensures that all other users migrate successfully!
		migrateUser("subbu");
		migrateUser("demo");
		migrateUser("quesoboy");

		for (User u: validatedUsers) {
			String uid = u.getUid();
			if (!uid.equals("subbu") && !uid.equals("demo") && !uid.equals("quesoboy")) {
				System.out.println("UID: " + u.getUid());
				try { u.validateIssues(true); } catch (Exception e) { _log.error("ERROR VALIDATING:", e); }
			}
		}

		System.out.println("Done!");
	}

	public static void main(String[] args)
	{
		if (args.length < 2) {
			System.out.println("Usage: java newsrack.database.sql.scripts.UserMigration <properties-file> <action> [<other-optional-args>]");
			System.exit(0);
		}

   	String appPropertiesFile = args[0];
		String action = args[1];

		System.out.println("Properties file: " + appPropertiesFile);
		NewsRack.startup(null, appPropertiesFile);

		if (action.equals("migrate")) {
			migrateAllV1UsersToV2();
		}
		else if (action.equals("update")) {
			updateArtCounts();
		}
		else if (action.equals("migrate-user")) {
			migrateUser(args[2]);
		}
		else if (action.equals("fixup-feeds")) {
			updateFeedNames();
		}
		else {
			System.out.println("Unknown action:" + action);
		}
		System.out.println("All Done!");
		System.exit(0);
	}
}
