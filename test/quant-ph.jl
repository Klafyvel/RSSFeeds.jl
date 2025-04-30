using RSSFeeds
using Dates
using Test

@testset "Integration test on quant-ph arxiv feed." begin
    rss = parse(RSSFeeds.RSS, read(joinpath(@__DIR__, "quant-ph.xml")))
    @test rss.version == v"2"
    channel = rss.channel
    @test channel.title == "quant-ph updates on arXiv.org"
    @test channel.description == "quant-ph updates on the arXiv.org e-print archive."
    @test channel.lastBuildDate == DateTime(2025, 04, 28, 4)
    @test channel.docs == "http://www.rssboard.org/rss-specification"
    @test channel.language == "en-us"
    @test length(channel.items) == 81
end
