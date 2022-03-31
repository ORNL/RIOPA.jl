import MPI
import Test: @testset, @test, @test_throws

include("../../src/main.jl")

@testset "main" begin
    @test main(["hello"]) == 0
    @test_exists_and_rm("hello.h5")
    filename = "testcase-temp-config.yaml"
    @test main(["-c", filename, "generate-config"]) == 0
    @test_exists_and_rm(filename)
end
