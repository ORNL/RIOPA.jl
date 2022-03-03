
using Test

include("../../../src/core/inputs.jl")

@testset "test_inputs.jl" begin
    inputs = parse_inputs(["hello"])
    @test inputs.hello == "hello"

    @test_throws ArgumentError("RIOPA: input argument hello-fail is not valid") parse_inputs([
        "hello-fail",
    ])

    @test_throws ArgumentError("RIOPA: input arguments are not valid") parse_inputs([
        "hello-fail",
        "hello-fail-again",
    ])
end
