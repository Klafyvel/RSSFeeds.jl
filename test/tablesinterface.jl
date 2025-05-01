using Test
using RSSFeeds
using Tables

@testset "Tables.jl interface" begin
    # first, create a MatrixTable from our matrix input
    rss = parse(RSSFeeds.RSS, read(joinpath(@__DIR__, "bouletcorp.xml")))
    cols = ["All Cops are Blagueurs", "Aquapella", "Portier", "Streaming", "Ouverture Facile", "Un Royaume Magique", "Catch'em all!", "Visa Blues", "Le Joli Coco", "Le Joli Coco contre le Cartel Cubain"]
    @test Tables.istable(typeof(rss))
    # test that it defines column access
    @test Tables.columnaccess(typeof(rss))
    @test Tables.columns(rss) === rss
    @test Tables.getcolumn(rss, :title) == cols
    @test Tables.getcolumn(rss, 1) == cols
    @test Tables.columnnames(rss) == [fieldnames(RSSFeeds.RSSItem)[1:end-1]...]
end
