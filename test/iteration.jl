using Test
using RSSFeeds

@testset "Iteration interface" begin
    rss = parse(RSSFeeds.RSS, read(joinpath(@__DIR__, "bouletcorp.xml")))
    @test length(rss) == 10
    @test eltype(RSSFeeds.RSS) == RSSFeeds.RSSItem
    for item in rss
        @test item.title isa String
        @test item.description isa String
    end
end
