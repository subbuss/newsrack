package newsrack.database.sql.scripts;

public class NewsItemDTO {
   public String url;
   public String title;
   public String author;
   public String date;
   public String desc;
   public String feeds;
   public String cats;

	public NewsItemDTO() { }

   public void setUrl(String url) { this.url = url; }
   public void setTitle(String title) { this.title = title; }
   public void setAuthor(String author) { this.author = author; }
   public void setDate(String date) { this.date = date; }
   public void setDesc(String desc) { this.desc = desc; }
   public void setFeeds(String feeds) { this.feeds = feeds; }
   public void setCats(String cats) { this.cats = cats; }
}
