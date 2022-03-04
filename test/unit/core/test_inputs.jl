
module RiopaTesting

using MPI

function __init__()
    MPI.Init()
end

using Test

include("../../../src/core/inputs.jl")

@testset "test_inputs.jl" begin
    inputs = parse_inputs(["--hello"])
    @test inputs["hello"] == true

    @test_throws ArgParse.ArgParseError("too many arguments") parse_inputs([
        "hello-fail",
    ])

    # @test_throws ArgumentError("RIOPA: input arguments are not valid") parse_inputs([
    #     "hello-fail",
    #     "hello-fail-again",
    # ])
end

end
