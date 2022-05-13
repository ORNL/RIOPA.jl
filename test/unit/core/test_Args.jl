import ArgParse, RIOPA
import Test: @testset, @test, @test_throws

@testset "args" begin
    ArgError = ArgParse.ArgParseError

    inputs = RIOPA.parse_inputs(["hello"])
    @test inputs["%COMMAND%"] == "hello"

    @test_throws(
        ArgError("unknown command: hello-fail"),
        RIOPA.parse_inputs(
            ["hello-fail"],
            error_handler = ArgParse.debug_handler,
        )
    )

    @test_throws(
        ArgError("unrecognized option --hey"),
        RIOPA.parse_inputs(["--hey"], error_handler = ArgParse.debug_handler)
    )
end
