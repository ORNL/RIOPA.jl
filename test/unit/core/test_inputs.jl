using Test, ArgParse, MPI

# MPI.Init()

include("../../../src/core/inputs.jl")

@testset "cmdline" begin
    inputs = parse_inputs(["hello"])
    @test inputs["%COMMAND%"] == "hello"

    # because there are currently no positional arguments
    @test_throws ArgParseError("unknown command: hello-fail") parse_inputs(
        ["hello-fail"],
        error_handler = ArgParse.debug_handler,
    )

    @test_throws ArgParseError("unrecognized option --hey") parse_inputs(
        ["--hey"],
        error_handler = ArgParse.debug_handler,
    )
end

@testset "config" begin
    config = default_config()
    @test config[:io][:transport] == "HDF5"
    @test config[:io][:levels][3][:size] == [1.0e6, 3.0e6]
    filename = "testcase-temp-config.yaml"
    generate_config(filename)
    @test ispath(filename)
    config2 = read_config(filename)
    @test config2[:io][:transport] == "HDF5"
    @test config2[:io][:levels][3][:size] == [1.0e6, 3.0e6]
    @test config2 == config
    rm(filename)
end
