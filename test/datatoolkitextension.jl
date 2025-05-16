using Test
using DataToolkitCore
using DataToolkitCommon
using DataFrames
using RSSFeeds


DataToolkitCore.loadcollection!(joinpath(@__DIR__, "Data.toml"))

@testset "DataToolkit extension" begin
    @test size(read(dataset("bouletcorp"), DataFrame)) == (10,10)

end
