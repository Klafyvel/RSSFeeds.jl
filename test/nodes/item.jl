using RSSFeeds
using Test
using Dates
using XML

@testset "RSS channel node basics." begin
    item_str = raw"""
    <item>
        <title><![CDATA[Le Joli Coco contre le Cartel Cubain]]></title>
        <link>https://bouletcorp.com/notes/2024/01/05</link>
        <guid>1856</guid>
        <pubDate>Fri, 05 Jan 2024 00:00:00 GMT</pubDate>
        <description><![CDATA[Le Joli Coco contre le Cartel Cubain]]></description>
        <enclosure url="https://bouletcorp.com/uploads/Coco00b_342c71144b.jpg" length="0" type="image/jpg"/>
    </item>
    """
    item = RSSFeeds.parserss(RSSFeeds.RSSItem, first(XML.children(parse(XML.Node, item_str))), Dict())
    @test item.title == "Le Joli Coco contre le Cartel Cubain"
    @test item.link == "https://bouletcorp.com/notes/2024/01/05"
    @test item.guid.guid == "1856"
    @test item.pubDate == Dates.DateTime(2024, 01, 05)
    @test item.description == "Le Joli Coco contre le Cartel Cubain"
    @test item.enclosure.url == "https://bouletcorp.com/uploads/Coco00b_342c71144b.jpg"
    @test item.enclosure.length == 0
    @test item.enclosure.type == "image/jpg"
end

