import ArgParse, MPI, RIOPA
import Test: @testset, @test, @test_throws

@testset "cmdline" begin
    ArgError = ArgParse.ArgParseError

    inputs = RIOPA.parse_inputs(["hello"])
    @test inputs["%COMMAND%"] == "hello"

    # because there are currently no positional arguments
    @test_throws ArgError("unknown command: hello-fail") RIOPA.parse_inputs(
        ["hello-fail"],
        error_handler = ArgParse.debug_handler,
    )

    @test_throws ArgError("unrecognized option --hey") RIOPA.parse_inputs(
        ["--hey"],
        error_handler = ArgParse.debug_handler,
    )
end

@testset "config" begin
    config = RIOPA.default_config()
    @test config[:io][:transport] == "HDF5"
    @test config[:io][:levels][3][:size] == [1.0e6, 3.0e6]
    filename = "testcase-temp-config.yaml"
    RIOPA.generate_config(filename)
    @test ispath(filename)
    config2 = RIOPA.read_config(filename)
    @test config2[:io][:transport] == "HDF5"
    @test config2[:io][:levels][3][:size] == [1.0e6, 3.0e6]
    @test config2 == config
    rm(filename)
end
