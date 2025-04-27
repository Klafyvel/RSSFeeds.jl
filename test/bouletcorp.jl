using RSSFeeds
using Dates
using Test

@testset "Integration test on bouletcorp.com" begin
    rss = parse(RSSFeeds.RSS, read(joinpath(@__DIR__, "bouletcorp.xml")))
    @test rss.version == v"2"
    channel = rss.channel
    @test channel.title == "bouletcorp.com"
    @test length(channel.items) == 10
    @test channel.description == "Bouletcorp, le site web de Boulet."
    @test channel.lastBuildDate == DateTime(2025, 04, 26)
    @test channel.docs == "https://validator.w3.org/feed/docs/rss2.html"
    @test channel.generator == "https://github.com/nuxt-community/feed-module"
    @test channel.language == "fr"
    @test channel.copyright == "2023"
    @test channel.category == [RSSFeeds.RSSCategory(nothing, "Comics"), RSSFeeds.RSSCategory(nothing, "Comics")]
end


