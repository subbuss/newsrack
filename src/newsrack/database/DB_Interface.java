package newsrack.database;

import java.io.File;
import java.io.Reader;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.Date;
import java.util.Hashtable;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Iterator;
import newsrack.NewsRack;
import newsrack.archiver.Feed;
import newsrack.archiver.Source;
import newsrack.user.User;
import newsrack.filter.Category;
import newsrack.filter.Concept;
import newsrack.filter.Filter;
import newsrack.filter.Issue;
import newsrack.filter.PublicFile;
import newsrack.filter.NR_Collection;
import newsrack.filter.NR_CollectionType;

/**
 * class <code>DB_Interface</code> encodes an interface to the
 * database which stores all data -- information about users,
 * their profiles, and individual news archives.  By specifying
 * an abstract class, multiple different database implementations
 * can be chosen -- using OS files, using MySQL, or using Pantoto.
 * The rest of the code should work independent of the specific
 * database implementation chosen.
 *
 * @author Subramanya Sastry
 * @version 1.0 22/06/04
 */
public abstract class DB_Interface
{
	static protected String TMPDIR = "tmp";

	static public String LAST_LOGIN = "LAST_LOGIN";

/* #### GENERIC functions #### */
	/** This method initializes the DB interface */
	public abstract void       init();

	/** This method shuts down the DB interface */
	public abstract void       shutdown();

	public abstract void printStats();

	/** This method returns stats */
	public abstract String getStats();

	/** This method loads the user table */
	public abstract void       loadUserTable();

	/** This method returns the global news archive directory */
	public abstract String     getGlobalNewsArchive();

	/**
	 * Return the path name for a temporary file given a base name
	 * There is no guarantee that the base name will be part of the file path!
	 * @param base base name for the file
	 */
	public File getTempFilePath(String base)
	{
		return new File(NewsRack.getGlobalNewsArchive() + File.separator + TMPDIR + File.separator + "tmp." + base.hashCode());
	}

	/** This method clears out the cache */
	public abstract void clearCache();

	/** This method clears out the downloaded news table */
	public abstract void clearDownloadedNewsTable();

/* #### Support for Collections #### */
	/**
	 * @param fromUid  Uid of the user whose collection is being imported by another user
	 * @param toUid    Uid of the user who is importing a collection from another user
	 */
   public abstract void recordImportDependency(String fromUid, String toUid);

	/**
	 * Gets the list of users who have imported a user's collection
	 * @param u  User whose importers are required
	 */
	public abstract List<Long> getCollectionImportersForUser(User u);

	/**
	 * Gets the list of users who export collections for 'u'
	 * @param u  User whose importers are required
	 */
	public abstract List<Long> getCollectionExportersForUser(User u);

	/**
	 * Remove all of this users's import dependencies on other users
	 * @param u  User whose dependencies are to be removed
	 */
	public abstract void clearImportDependenciesForUser(User u);

	/**
	 * Record a collection (source, concept, category) with the database
	 * @param c The collection to be added
	 */
	public abstract void addProfileCollection(NR_Collection c);

	/**
	 * Gets a named collection for a user
	 * @param type  Type of collection to be fetched
	 * @param uid   User whose collection needs to be fetched 
	 * @param name  Name of the collection
	 */
	public abstract NR_Collection getCollection(NR_CollectionType type, String uid, String name);

	public abstract Source   getSourceFromCollection(long collectionKey, String name);
	public abstract Concept  getConceptFromCollection(long collectionKey, String name);
	public abstract Filter   getFilterFromCollection(long collectionKey, String name);
	public abstract Category getCategoryFromCollection(long collectionKey, String name);

	public abstract List<Source> getAllSourcesFromCollection(long collectionKey);
	public abstract List<Concept> getAllConceptsFromCollection(long collectionKey);
	public abstract List<Filter> getAllFiltersFromCollection(long collectionKey);
	public abstract List<Category> getAllCategoriesFromCollection(long collectionKey);

/* #### Support for Feeds #### */

	/**
	 * Returns a system-wide unique id (string) for a rss feed with given URL.
	 * @param feedURL  URL of the rss feed whose id is requested
	 * @param sTag     Source tag used by the user (non-unique)
	 * @param feedName Name for the feed (for use in webpages and rss feeds)
	 */
	//public abstract String getUniqueFeedTag(final String feedURL, final String sTag, final String feedName);
	//

	/**
	 * Returns a feed object for a rss feed, if one exists in the database.
	 * A new entry is created in the database, if necessary
	 *
	 * @param feedURL  URL of the rss feed whose id is requested
	 * @param sTag     Source tag used by the user (non-unique), can be null
	 * @param feedName Name for the feed (for use in webpages and rss feeds), can be null
	 */
	public abstract Feed getFeed(final String feedURL, final String sTag, final String feedName);

	public abstract Feed getFeed(Long key);

   public abstract List<Feed>  getAllFeeds();

	/**
	 * This method returns a list of all active feeds.
	 * A feed is considered active if some topic is monitoring the feed.
	 */
   public abstract List<Feed>  getAllActiveFeeds();

	/**
	 * This method updates the database with changes made to a feed
	 * @param f Feed whose info. needs to be updated
	 */
	public abstract void updateFeedCacheability(Feed f);

	/**
	 * Gets the list of downloaded news items for a feed in the most recent download phase
	 */
	public abstract Collection<NewsItem> getDownloadedNews(Feed f);

  /**
	 * This method goes through the entire news archive and fetches news
	 * indexes for a desired feed.  Note that for the same feed, 
    * multiple indexes can be returned.  This can happen, for instance,
    * when the news archive is organized by date, and so, the iterator will
    * return one news index for each date.
	 *
	 * @param feedKey Key of the feed for which indexes have to be fetched
	 * @param sd  Start date (inclusive) from which indexes have to be fetched
	 * @param ed  End date (inclusive) beyond which indexes should not be fetched
	 */
	public abstract Iterator<? extends NewsIndex> getIndexesOfAllArchivedNews(Long feedKey, Date sd, Date ed);

/* #### Support for Source #### */

	public abstract Source getSource(Long key);

	/**
	 * Get a source object given a src tag, the user defining it
	 * @param u       user requesting the source 
	 * @param tag     tag assigned by the user to the feed
	 */
	public abstract Source getSource(User u, String tag);

	/**
	 * Get a source object given a src tag, and the topic that monitors it 
	 * @param i       topic monitoring the source 
	 * @param tag     tag assigned by the user to the feed
	 */
	public abstract Source getSource(Issue i, String tag);

/* #### Support for User #### */
	/**
	 * This method registers the user with the database .. in the process,
	 * it might initialize user space.
	 *
	 * @param u   User who has to be registered
	 */
	public abstract void registerUser(User u);

   public abstract List<User> getAllUsers();
	public abstract User getUser(Long key);
   public abstract User getUser(String uid); 

	/**
	 * This method updates the database with changes made to an user's entry
	 * @param u User whose info. needs to be updated 
	 */
	public abstract void updateUser(User u);

	/**
	 * This method updates a user attribute in the db (ex: registration date, last login, last edit, etc.)
	 */
	public abstract void updateUserAttribute(User u, String attr, Object value);

	/**
	 * The profile of the user is initialized from the database
	 * reading any configuration files, initializing fields, etc.
	 * for the user.
	 *
	 * @param u  User whose profile has to be initialized
	 */
   public abstract void initProfile(User u) throws Exception;

	/**
	 * Invalidate the user's profile -- this invalides
	 * all the user's entries in the database.  But, it retains
	 * news and some information about topics so that when the
	 * profile is revalidated, news previously classified continues
	 * to be available
	 */
	public abstract void invalidateUserProfile(User u);

	/**
	 * Gets the set of all sources monitored by the user across all topics 
	 */
	public abstract Collection<Source> getMonitoredSourcesForAllTopics(User u);

/* #### Support for user files #### */

	/**
	 * This method returns the path of a work directory for the user
	 * @param u  User who requires the work directory
	 */
	public abstract String getUserSpaceWorkDir(User u);

	/**
	 * This method returns the file upload area
	 * @param u   User who is upload files
	 */
	public abstract String getFileUploadArea(User u);

	/**
	 * This method returns byte stream for reading a file in a user's space
	 *
	 * @param u      The user whose user space is being accessed
	 * @param fname  The file being read.
	 * @return Returns a byte stream for reading the file
	 */
	public abstract InputStream getInputStream(User u, String fname) throws java.io.IOException;

	/**
	 * This method returns a character reader for reading a file in a user's space
	 *
	 * @param u      The user whose user space is being accessed
	 * @param fname  The file being read.
	 * @return Returns a reader for reading the file
	 */
	public abstract Reader getFileReader(User u, String fname) throws java.io.IOException;

	/**
	 * This method returns an output stream for writing a file in a user's space
	 *
	 * @param u      The user whose user space is being accessed
	 * @param fname  The file being written to.
	 * @return Returns an output stream for writing the file
	 */
	public abstract OutputStream getOutputStream(User u, String fname) throws java.io.IOException;

	/**
	 * This method returns a byte stream for reading a file in some user's space
	 * different from the user who is using the system.  Note that the download will
	 * succeed only if the user requesting the file has appropriate access rights.
	 *
	 * @param reqUser The user who is requesting the file.
	 * @param uid     The user whose file is being requested.
	 * @param fname   Name of the file being requested.
	 * @return        Returns a byte stream for reading the file, if the file
	 *                exists and is accessible.  Else throws an IO exception
	 */
	public abstract InputStream getInputStream(User reqUser, String uid, String fname) throws java.io.IOException;

	/**
	 * This method returns a character reader for reading a file in some user's space
	 * different from the user who is using the system.  Note that the download will
	 * succeed only if the user requesting the file has appropriate access rights.
	 *
	 * @param reqUser The user who is requesting the file.
	 * @param uid     The user whose file is being requested.
	 * @param fname   Name of the file being requested.
	 * @return        Returns a reader for reading the file, if the file
	 *                exists and is accessible.  Else throws an IO exception
	 */
	public abstract Reader getFileReader(User reqUser, String uid, String fname) throws java.io.IOException;

	/**
	 * This method deletes a file from the user's space
	 *
	 * @param u    User who has requested a file to be deleted
	 * @param name The file to be deleted
	 */
	public abstract void deleteFile(User u, String name);

	/**
	 * This method uploads a file from the user's computer to the user's info space.
	 * The file in the user's space will have the same base name as the file being
	 * uploaded.  For example, if the user is uploading "../../myfiles/my.concepts.xml"
	 * the uploaded file will have the name "my.concepts.xml".
	 *
	 * NOTE: The caller is responsible for closing the input stream
	 *
	 * @param fname The name of the local file into which the file should be uploaded.
	 * @param is    The input stream from which the file should be uploaded. 
	 * @param u     The user who is uploaded the file .
	 */
	public abstract void uploadFile(String fname, InputStream is, User u) throws java.io.IOException;

	/**
	 * This method adds a file to the user's info space
	 *
	 * @param is The input stream from which the file should be uploaded. 
	 * @param u  The user who is uploaded the file .
	 */
	public abstract void addFile(String fname, User u) throws java.io.IOException;

	/**
	 * This method provides a path in the local file system for a file
	 * in the user's space.  Note that this ptth might be a temporary
	 * path where the file has been made available.
	 */
	public abstract String getRelativeFilePath(User u, String fname);

	/** Get a list of all user files for a given user */
   public abstract List<String> getFiles(User u);

	/** Get a list of all public user file names */
   public abstract List<PublicFile> getAllPublicUserFiles();

/* #### Support for Issue #### */
	public abstract Issue getIssue(Long key);
   public abstract Issue getIssue(User u, String issue);
   public abstract List<Issue> getIssues(User u);
   public abstract List<Issue> getAllValidatedIssues();
   public abstract List<Issue> getAllIssues();
	/**
	 * This method updates the database with changes made to an issue
	 * @param i Issue that needs to be updated
	 */
	public abstract void updateTopic(Issue i);

	/**
	 * Add an issue to the database
	 * @param i  Issue that needs to be added
	 */
	public abstract void addIssue(Issue i);

	/**
	 * Change the status of the issue and all containing categories to invalid
	 *
	 * SSS: Right now, only way to invalidate an issue is by invalidating everything!
	 *
	public abstract void invalidateIssue(Issue i);
	 */

	/**
	 * Remove the issue from the database.
	 * @param i   Issue that needs to be removed.
	 */
	public abstract void removeIssue(Issue i);

	/**
	 * Return classified news from an issue
	 * @param i           Issue from which to fetch news
	 * @param start       starting date (in yyyy.mm.dd format)
	 * @param end         end date      (in yyyy.mm.dd format)
	 * @param src         The source from which news is needed
	 * @param startIndex  starting article
	 * @param numArts     number of articles to fetch
	 */
	//public abstract List<NewsItem> getNews(Issue i, Date start, Date end, Source src, int startIndex, int numArts);

/* #### Support for Concept #### */
	public abstract Concept getConcept(Long key);
   public abstract void updateConceptLexerToken (Concept c);

/* #### Support for Filter #### */
	public abstract Filter getFilter(Long key);

/* #### Support for Category #### */
	public abstract Category getCategory(Long key);

	/**
	 * Add a category to the database
	 * @param uKey user that defined this category
	 * @param c Category that needs to be added
	 */
/**
 * SSS: maybe not being added directly!
 *
	public abstract void addCategory(Long uKey, Category c);
 **/

	/**
	 * Remove a category from the database.
	 * @param c Category that needs to be removed
	 */
	public abstract void removeCategory(Category c);

	/**
	 * Remove a classified news item from a category
	 * @param catKey   Category key (globally unique)
	 * @param niKey    NewsItem key (globally unique)
	 */
	public abstract void deleteNewsItemFromCategory(Long catKey, Long niKey);

	/**
	 * Remove a classified news item from a category
	 * @param catKey   Category key (globally unique)
	 * @param niKeys   NewsItem keys (globally unique)
	 */
	public abstract void deleteNewsItemsFromCategory(Long catKey, List<Long> niKeys);

	/**
	 * Checks if a category contains a news item
	 * @param c    Category which needs to be checked
	 * @param ni   News Item that needs to be checked
	 * @return true if category c contains the news item ni
	 */
	public abstract boolean newsItemPresentInCategory(Category c, NewsItem ni);

	/**
	 * Record a classified news item!
	 * @param ni   News Item that has been classified in category c
	 * @param c    Category into which ni has been classified
	 * @param matchCount  Match weight
	 */
	public abstract void addNewsItem(NewsItem ni, Category c, int matchCount);

	/**
	 * Gets list of articles classified in a category
	 * @param cat     Category for which news is being sought
	 * @param numArts Number of articles requested
	 */
	public abstract List<NewsItem> getNews(Category cat, int numArts);

	/**
	 * Return classified news from a category (leaf or non-leaf)
	 * @param c           Category to fetch news from
	 * @param start       starting date (in yyyy.mm.dd format)
	 * @param end         end date      (in yyyy.mm.dd format)
	 * @param src         The source from which news is needed
	 * @param startIndex  starting article
	 * @param numArts     number of articles to fetch
	 */
	public abstract List<NewsItem> getNews(Category c, Date start, Date end, Source src, int startIndex, int numArts);

	/**
	 * Gets list of articles classified in a category
	 * -- starting at a specified index
	 * @param cat	   Category for which news is being sought
	 * @param startId The starting index
	 * @param numArts Number of articles requested
	 */
	public abstract List<NewsItem> getNews(Category cat, int startId, int numArts);

	/**
	 * Clears the list of articles classified in a category
	 * @param c Category for which news is to be cleared
	 */
	public abstract void clearNews(Category c);

	/**
	 * Fetches a news item given its key
	 */
	public abstract NewsItem getNewsItem(Long key);

	/**
	 * This method returns a character reader for displaying a news item
	 * that has been archived in the local installation of News Rack.
	 *
	 * @param ni  NewsItem for which a reader is needed
	 * @return Returns a reader object for reading the news item
	 */
	public abstract Reader getNewsItemReader(NewsItem ni) throws java.io.IOException;

	/**
	 * This method returns a NewsItem object for an article
	 * that has already been downloaded
	 *
	 * @param url   URL of the article
	 * @returns a news item object for the article
	 */
	public abstract NewsItem getNewsItemFromURL(String url);

	/**
	 * This method returns a NewsItem object for an article
	 * that has already been downloaded
	 *
	 * @param path   Path of the local copy of the article
	 * @returns a news item object for the article
	 */
	public abstract NewsItem getNewsItemFromLocalCopyPath(String path);

	/**
	 * This method returns a NewsItem object for an article, if it has already
	 * been downloaded.  In an ideal world, only the URL is sufficient, but, in
	 * some cases, providing more details guarantees greater success of finding
	 * an existing object!  TODO: In other words, till such time NewsRack stabilizes,
	 * and caching works properly in the face of crashes and improper shutdowns, 
	 * the extra information is needed to find already downloaded news items)
	 *
	 * @param url      URL of the article
	 * @param f        News feed object
	 * @param d        Date of publishing
	 * @param baseName Expected base name of the article in the archives
	 * @returns a news item object for the article
	 */
	public abstract NewsItem getNewsItem(String url, Feed f, Date d, String baseName);

	/**
	 * This method creates a NewsItem object for the specified article.
	 * This method won't be stored into the db till it is asked to be stored.
	 *
	 * @param url      URL of the article
	 * @param f        News feed object
	 * @param d        Date of publishing
	 * @returns a news item object for the article
	 */
	public abstract NewsItem createNewsItem(String url, Feed f, Date d);

	/**
	 * Record a downloaded news item
	 *
	 * @param f  News feed from where the news item was downloaded 
	 * @param ni The downloaded news item
	 *
	 * NOTE: ni is not guaranteed to be a news item that has been
	 * newly downloaded ... it could as well be a news item that has
	 * been obtained by querying the database.
	 */
	public abstract void recordDownloadedNewsItem(Feed f, NewsItem ni);

	/**
	 * returns true if a news item has been processed for an issue -- to avoid
	 * reprocessing the same news item over and over
	 *
	 * NOTE: This method and the updateMaxNewsIdForIssue method assume that
	 * ids of news items increase monotonically as new items are downloaded. 
	 * This is probably not the best design decision ... but, for now, this is how it is.
	 */
	public abstract boolean newsItemHasBeenProcessedForIssue(NewsItem ni, Issue i);

	/**
	 * Get a print writer for writing the raw HTML of the article into
	 *
	 * @param ni The news item for which the writer is requested
    *
    * @returns null if a file exists for this news item!
	 */
	public abstract PrintWriter getWriterForOrigArticle(NewsItem ni);

	/**
	 * Get a print writer for writing the filtered article into (i.e. after their text 
	 * content is extracted)
	 *
	 * @param ni The news item for which the writer is requested
    *
    * @returns null if a file exists for this news item!
	 */
	public abstract PrintWriter getWriterForFilteredArticle(NewsItem ni);

	/**
	 * Delete the requested filtered article from the archive!
	 *
	 * @param ni The news item that is to be deleted from the archive
	 */
	public abstract void deleteFilteredArticle(NewsItem ni);

/* #### News Download Phase #### */
	/**
	 * Initialize the database for downloading news for a particular date
	 * from a particular source
	 *
	 * @param f        Feed from which news is being downloaded
	 * @param pubDate  Date for which news is being downloaded
	 */
	public abstract void initializeNewsDownload(Feed f, Date pubDate);

	/**
	 * Perform any necessary clean up after news download is finished
	 * from a particular source
	 *
	 * @param f feed from which news was downloaded
	 */
	public abstract void finalizeNewsDownload(Feed f);

	/**
	 * updates the max id of the news item that has been processed for an issue for a given feed.
	 *
	 * NOTE: This method and the newsItemHasBeenProcessedForIssue method assume that
	 * ids of news items increase monotonically as new items are downloaded. 
	 * This is probably not the best design decision ... but, for now, this is how it is.
	 */
	public abstract void updateMaxNewsIdForIssue(Issue i, Feed f, Long maxId);

	public abstract void resetMaxNewsIdForIssue(Issue i);

	/**
	 * This method commits filtered news for an issue
	 * @param i	Issue for which news has to be committed
	 */
	public abstract void commitNewsToArchive(Issue i);

/* #### Support for News Indexes #### */
   /** Gets the newsindex object given its key */
      public abstract NewsIndex getNewsIndex(Long key);

	/**
	 * Get the directory where index files and rss files for a feed
	 * for a particular date is stored
	 *
	 * @param f     news feed
	 * @param date  Date when news is being downloaded
	 */
	public abstract String getArchiveDirForIndexFiles(Feed f, Date date);

	/**
	 * This method reads news from the archive and returns a collection of news items.
	 *
	 * @param index  News Index representing the news that should be read.
	 */
	public abstract Collection<NewsItem> getArchivedNews(NewsIndex index);

	/**
	 * This method goes through the news archive and fetches news
	 * for a desired news source for a desired date.
	 *
	 * @param s  Source for which news has to be fetched
	 * @param y  Year for which news has to be fetched
	 * @param m  Month for which news has to be fetched
	 * @param d  Date for which news has to be fetched
	 */
	public abstract Collection<NewsItem> getArchivedNews(Source s, String y, String m, String d);

	/**
	 * This method goes through the entire news archive and fetches news
	 * indexes for a desired news source.  Note that for the same
	 * news source, multiple indexes can be returned.  This can happen,
	 * for instance, when the news archive is organized by date, and so,
	 * the iterator will return one news index for each date.
	 *
	 * @param s   Source for which news indexes have to be fetched
	 */
	public abstract Iterator<? extends NewsIndex> getIndexesOfAllArchivedNews(Source s);

	/**
	 * This method goes through the entire news archive and fetches news
	 * indexes for a desired news source.  Note that for the same
	 * news source, multiple indexes can be returned.  This can happen,
	 * for instance, when the news archive is organized by date, and so,
	 * the iterator will return one news index for each date.
	 *
	 * @param s   Source for which news indexes have to be fetched
	 * @param sd  Start date (inclusive) from which indexes have to be fetched
	 * @param ed  End date (inclusive) beyond which indexes should not be fetched
	 */
	public abstract Iterator<? extends NewsIndex> getIndexesOfAllArchivedNews(Source s, Date sd, Date ed);
}
