package newsrack.database.sql;

public enum SQL_ColumnSize
{
   NONE(-1),
   USER_TBL_UID(20),
   USER_TBL_PASSWORD(50),
   USER_TBL_NAME(50),
   USER_TBL_EMAIL(50),
   USER_FILES_TBL_FILENAME(255),
   ISSUE_TBL_NAME(50),
   CAT_TBL_NAME(50),
   NEWS_INDEX_TBL_DATESTRING(10),
   NEWS_ITEM_TBL_URLROOT(100),
   NEWS_ITEM_TBL_URLTAIL(255),
   NEWS_ITEM_TBL_LOCALNAME(255),
   FEED_TBL_FEEDTAG(50),
   FEED_TBL_FEEDURL(255),
   USER_SOURCE_TBL_UTAG(255);

   public final int _size;

   SQL_ColumnSize(int n) { _size = n; }
}
