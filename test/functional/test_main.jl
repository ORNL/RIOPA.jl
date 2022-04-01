import MPI, HDF5
import Test: @testset, @test, @test_throws

include("../../src/main.jl")

@testset "main" begin
    @test main(["hello"]) == 0
    if HDF5.has_parallel()
        @test_exists_and_rm("hello.h5")
    else
        @test_exists_and_rm("hello_0.h5")
    end
    filename = "testcase-temp-config.yaml"
    @test main(["-c", filename, "generate-config"]) == 0
    @test_exists_and_rm(filename)
end
