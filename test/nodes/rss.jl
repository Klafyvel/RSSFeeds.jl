using RSSFeeds
using Test

@testset "RSS feed node basics." begin
    feed = raw"""
    <?xml version='1.0' encoding='UTF-8'?>
    <rss xmlns:arxiv="http://arxiv.org/schemas/atom" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:content="http://purl.org/rss/1.0/modules/content/" version="2.0">
      <channel>
        <title>cs updates on arXiv.org</title>
        <link>http://rss.arxiv.org/rss/cs</link>
        <description>cs updates on the arXiv.org e-print archive.</description>
        <atom:link href="http://rss.arxiv.org/rss/cs" rel="self" type="application/rss+xml"/>
        <docs>http://www.rssboard.org/rss-specification</docs>
        <language>en-us</language>
        <lastBuildDate>Sun, 27 Apr 2025 04:00:00 +0000</lastBuildDate>
        <managingEditor>rss-help@arxiv.org</managingEditor>
        <pubDate>Sun, 27 Apr 2025 00:00:00 -0400</pubDate>
        <skipDays>
          <day>Saturday</day>
          <day>Sunday</day>
        </skipDays>
      </channel>
    </rss>
    """
    rss = RSSFeeds.parserss(RSSFeeds.RSS, feed)
    @test rss.version == v"2.0"
    @test rss.channel isa RSSFeeds.RSSChannel
end
