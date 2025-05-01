using RSSFeeds
using Test
using Aqua
using JET

@testset "RSSFeeds.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(RSSFeeds)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(RSSFeeds; target_defined_modules = true)
    end
    include("rfc822datetime.jl")
    include("nodes/channel.jl")
    include("nodes/item.jl")
    include("nodes/rss.jl")
    include("bouletcorp.jl")
    include("iteration.jl")
    include("quant-ph.jl")
    include("tablesinterface.jl")
end
