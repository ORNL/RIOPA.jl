import RIOPA
import Test: @testset, @test, @test_throws

@testset "get_evolution_function" begin
    f = RIOPA.get_evolution_function("GrowthFactor", [1.1])
    @test f == RIOPA.GrowthFactorEvFn(1.1)
    f = RIOPA.get_evolution_function("growthfactor", [1.2])
    @test f == RIOPA.GrowthFactorEvFn(1.2)
    f = RIOPA.get_evolution_function("GROWTHFACTOR", [1.3])
    @test f == RIOPA.GrowthFactorEvFn(1.3)

    f = RIOPA.get_evolution_function("Polynomial", [1.0, 1.0])
    @test f == RIOPA.PolynomialEvFn([1.0, 1.0])
    f = RIOPA.get_evolution_function("polynomial", [1.0, 1.0])
    @test f == RIOPA.PolynomialEvFn([1.0, 1.0])
    f = RIOPA.get_evolution_function("POLYNOMIAL", [1.0, 1.0])
    @test f == RIOPA.PolynomialEvFn([1.0, 1.0])

    f = RIOPA.get_evolution_function("Constant", [1000, 1000])
    @test typeof(f) == RIOPA.ConstantEvFn
    f = RIOPA.get_evolution_function("constant", [1000, 2000])
    @test typeof(f) == RIOPA.ConstantEvFn
    f = RIOPA.get_evolution_function("CONSTANT", [1000, 3000])
    @test typeof(f) == RIOPA.ConstantEvFn

    pieces = [
        RIOPA.Config(
            :step => 0,
            :function => "Constant",
            :params => [3000, 3600],
        ),
        RIOPA.Config(
            :step => 20,
            :function => "Constant",
            :params => [4000, 4800],
        ),
        RIOPA.Config(
            :step => 60,
            :function => "Constant",
            :params => [8000, 9600],
        ),
        RIOPA.Config(:step => 100),
    ]
    f = RIOPA.get_evolution_function("Piecewise", pieces)
    @test typeof(f) == RIOPA.PiecewiseEvFn
    @test f.fns[1].step == 0
    @test typeof(f.fns[1].fn) == RIOPA.ConstantEvFn
    @test f.fns[1].fn.range == (3000, 3600)
    @test f.fns[2].step == 20
    @test typeof(f.fns[2].fn) == RIOPA.ConstantEvFn
    @test f.fns[2].fn.range == (4000, 4800)
    @test f.fns[3].step == 60
    @test typeof(f.fns[3].fn) == RIOPA.ConstantEvFn
    @test f.fns[3].fn.range == (8000, 9600)
    @test f.fns[4].step == 100
    f = RIOPA.get_evolution_function("piecewise", pieces)
    @test typeof(f) == RIOPA.PiecewiseEvFn
    f = RIOPA.get_evolution_function("PIECEWISE", pieces)
    @test typeof(f) == RIOPA.PiecewiseEvFn
end

@testset "evolution" begin
    stream = RIOPA.DataStream(
        RIOPA.PayloadRange(10, 20),
        1.0,
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
        1.0,
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
