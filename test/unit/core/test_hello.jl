import ArgParse, MPI, HDF5, RIOPA
import Test: @testset, @test, @test_throws

@testset "hello" begin
    RIOPA.hello(nothing)
    if HDF5.has_parallel()
        @test_exists_and_rm "hello.h5"
    else
        @test_exists_and_rm "hello_0.h5"
    end
end
