import ArgParse, MPI, RIOPA
import Test: @testset, @test, @test_throws

@testset "hello" begin
    RIOPA.hello(nothing)
    @test_exists_and_rm("hello_0.h5")
end
