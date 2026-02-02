{ ... }:

{
	programs.newsboat.urls = [
		{
			url = "https://feeds.bbci.co.uk/news/politics/rss.xml";
			tags = [ "news" "politics" ];
			title = "BBC Politics";
		}
		{
			url = "https://feeds.bbci.co.uk/news/business/rss.xml";
			tags = [ "news" "business" ];
			title = "BBC Business";
		}
		{
			url = "https://feeds.bbci.co.uk/news/science_and_environment/rss.xml";
			tags = [ "news" "science" ];
			title = "BBC Science and Environment";
		}
		{
			url = "https://www.theverge.com/rss/science/index.xml";
			tags = [ "news" "science" ];
			title = "The Verge: Science";
		}
		{
			url = "https://feeds.bbci.co.uk/news/world/rss.xml";
			tags = [ "news" "world" ];
			title = "BBC World News";
		}
		{
			url = "https://feeds.bbci.co.uk/news/entertainment_and_arts/rss.xml";
			tags = [ "news" "entertainment" ];
			title = "BBC Entertainment";
		}
		{
			url = "https://billboard.com/feed";
			tags = [ "news" "entertainment" ];
			title = "Billboard";
		}
		{
			url = "https://pitchfork.com/feed/feed-news/rss";
			tags = [ "news" "entertainment" ];
			title = "Pitchfork";
		}
		{
			url = "https://techcrunch.com/feed/";
			tags = [ "news" "technology" ];
			title = "Tech Crunch";
		}
		{
			url = "https://gizmodo.com/rss/";
			tags = [ "news" "technology" ];
			title = "Gizmodo";
		}
		{
			url = "https://lifehacker.com/index.xml";
			tags = [ "news" "technology" ];
			title = "LifeHacker";
		}
		{
			url = "https://feeds.bbci.co.uk/news/technology/rss.xml";
			tags = [ "news" "technology" ];
			title = "BBC Technology";
		}
		{
			url = "https://engadget.com/rss.xml";
			tags = [ "news" "technology" ];
			title = "Engadget";
		}
		{
			url = "https://www.wired.com/feed/rss";
			tags = [ "news" "technology" ];
			title = "Wired";
		}
		{
			url = "http://feeds.arstechnica.com/arstechnica/index/";
			tags = [ "news" "technology" ];
			title = "Ars Technica";
		}
		{
			url = "https://hackernewsrss.com/feed.xml";
			tags = [ "news" "technology" ];
			title = "Hacker News";
		}
		{
			url = "https://hn.invades.space/hn_gems_rss.xml";
			tags = [ "news" "technology" ];
			title = "Top Hacker News";
		}
		{
			url = "https://www.theverge.com/rss/cyber-security/index.xml";
			tags = [ "news" "cybersecurity" ];
			title = "The Verge: Cybersecurity";
		}
		{
			url = "https://portswigger.net/research/rss";
			tags = [ "news" "cybersecurity" ];
			title = "Portswigger Research";
		}
	];
}
