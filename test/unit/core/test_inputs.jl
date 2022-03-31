import ArgParse, RIOPA
import Test: @testset, @test, @test_throws

@testset "args" begin
    ArgError = ArgParse.ArgParseError

    inputs = RIOPA.parse_inputs(["hello"])
    @test inputs["%COMMAND%"] == "hello"

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
    @test config[:datasets][1][:transport] == "HDF5"
    @test config[:datasets][1][:data_streams][1][:proc_payloads][2][:size_range] ==
          [10, 20]
    @test config[:datasets][1][:data_streams][1][:proc_payloads][2][:ratio] == 0.94
    filename = "testcase-temp-config.yaml"
    RIOPA.generate_config(filename)
    @test ispath(filename)
    config2 = RIOPA.read_config(filename)
    @test config2 == config
    rm(filename)
end
