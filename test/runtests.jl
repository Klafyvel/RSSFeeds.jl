using RSS
using Test
using Aqua
using JET

@testset "RSS.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(RSS)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(RSS; target_defined_modules = true)
    end
    # Write your tests here.
end
