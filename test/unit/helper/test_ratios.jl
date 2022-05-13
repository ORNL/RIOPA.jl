import RIOPA
import Test: @testset, @test, @test_throws

@testset "ratios" begin
    @test parse(Rational{Int32}, "1/4") == 1 // 4
    @test parse(Rational{Int32}, "1//4") == 1 // 4
    @test parse(Rational, "1/4") == 1 // 4
    @test parse(Rational, "1//4") == 1 // 4

    @test RIOPA.get_ratio(0.2) == 0.2
    @test RIOPA.get_ratio("0.3") == 0.3
    @test RIOPA.get_ratio("1/4") == 0.25
    @test RIOPA.get_ratio("1//4") == 0.25
end
