using Test, ArgParse

include("../../../src/core/inputs.jl")

@testset "cmdline" begin
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

@testset "config" begin
    config = default_config()
    @test config[:io][:transport] == "HDF5"
    @test config[:io][:levels][3][:size] == [1.0e6, 3.0e6]
    generate_config()
    @test ispath("config.yaml")
    config2 = read_config("config.yaml")
    @test config2[:io][:transport] == "HDF5"
    @test config2[:io][:levels][3][:size] == [1.0e6, 3.0e6]
    @test config2 == config
end
