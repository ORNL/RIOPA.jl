import RIOPA
import Test: @testset, @test, @test_throws

@testset "evolution" begin
    stream = RIOPA.DataStream(
        RIOPA.PayloadRange(10, 20),
        RIOPA.GrowthFactorEvFn(1.5),
    )
    RIOPA.evolve_payload_range!(stream, 1)
    @test stream.range.a == 15
    @test stream.range.b == 30
    RIOPA.evolve_payload_range!(stream, 2)
    @test stream.range.a == 22
    @test stream.range.b == 45
    RIOPA.evolve_payload_range!(stream, 3)
    @test stream.range.a == 34
    @test stream.range.b == 68

    stream = RIOPA.DataStream(
        RIOPA.PayloadRange(10, 20),
        RIOPA.PolynomialEvFn([0, 1]),
    )
    RIOPA.evolve_payload_range!(stream, 1)
    @test stream.range.a == 11
    @test stream.range.b == 21
    RIOPA.evolve_payload_range!(stream, 2)
    @test stream.range.a == 14
    @test stream.range.b == 24
    RIOPA.evolve_payload_range!(stream, 3)
    @test stream.range.a == 19
    @test stream.range.b == 29
end
