import MPI, HDF5, RIOPA
import Test: @testset, @test, @test_throws

@testset "main" begin
    @test RIOPA.main(["hello"]) == 0
    if HDF5.has_parallel()
        @test_exists_and_rm("hello.h5")
    else
        @test_exists_and_rm("hello_0.h5")
    end
    filename = "testcase-temp-config.yaml"
    @test RIOPA.main(["-c", filename, "generate-config"]) == 0
    @test_exists_and_rm(filename)
end
