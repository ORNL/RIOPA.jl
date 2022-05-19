import RIOPA
import Test: @testset, @test, @test_throws

struct TestIOTag <: RIOPA.IO.IOTag end

@testset "IO" begin
    @test RIOPA.IO.get_tag(nothing) == RIOPA.IO.DefaultIOTag()
    @test_throws KeyError RIOPA.IO.get_tag("test")
    RIOPA.IO.add("test", TestIOTag())
    @test RIOPA.IO.get_tag("test") == TestIOTag()
end
