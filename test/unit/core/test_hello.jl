import ArgParse, MPI, RIOPA
import Test: @testset, @test, @test_throws

@testset "hello" begin
    RIOPA.hello(nothing)
    filename = "hello_0.dat"
    @test ispath(filename)
    rm(filename)
end
