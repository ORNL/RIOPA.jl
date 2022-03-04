using Test, ArgParse

include("../../../src/core/inputs.jl")

@testset "inputs" begin
    inputs = parse_inputs(["--hello"])
    @test inputs["hello"] == true

    # because there are currently no positional arguments
    @test_throws ArgParse.ArgParseError("too many arguments") parse_inputs(
        ["hello-fail"],
        error_handler = ArgParse.debug_handler,
    )

    @test_throws ArgParse.ArgParseError("unrecognized option --hey") parse_inputs(
        ["--hey"],
        error_handler = ArgParse.debug_handler,
    )
end
