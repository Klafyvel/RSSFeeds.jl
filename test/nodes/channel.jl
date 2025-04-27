using RSSFeeds
using Test
using Dates
using XML

@testset "RSS channel node basics." begin
    feed = raw"""
    <rss version="2.0">
      <channel>
          <title>bouletcorp.com</title>
          <link>https://bouletcorp.com</link>
          <description>Bouletcorp, le site web de Boulet.</description>
          <lastBuildDate>Tue, 18 Mar 2025 00:00:00 GMT</lastBuildDate>
          <docs>https://validator.w3.org/feed/docs/rss2.html</docs>
          <generator>https://github.com/nuxt-community/feed-module</generator>
          <language>fr</language>
          <copyright>2023</copyright>
          <category>Comics</category>
      </channel>
    </rss>
    """
    rss = RSSFeeds.parserss(RSSFeeds.RSS, feed)
    channel = rss.channel
    @test channel.title == "bouletcorp.com"
    @test channel.link == "https://bouletcorp.com"
    @test channel.description == "Bouletcorp, le site web de Boulet."
    @test channel.language == "fr"
    @test channel.copyright == "2023"
    @test isnothing(channel.managingEditor)
    @test isnothing(channel.webMaster)
    @test channel.generator == "https://github.com/nuxt-community/feed-module"
    @test channel.docs == "https://validator.w3.org/feed/docs/rss2.html"
    @test isnothing(channel.rating)
    @test isnothing(channel.pubDate)
    @test channel.lastBuildDate == DateTime(2025, 03, 18)
    @test channel.category == [RSSFeeds.RSSCategory(nothing, "Comics")]
end

@testset "RSS channel node extensions." begin
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
    channel = rss.channel
    @test length(XML.attributes(channel.atom.link)) == 3
    @test XML.attributes(channel.atom.link)["href"] == "http://rss.arxiv.org/rss/cs"
end

