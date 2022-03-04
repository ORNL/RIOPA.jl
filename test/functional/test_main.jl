
using Test, MPI, ArgParse

MPI.Init()

include("../../src/main.jl")

@testset "main" begin
    @test main(["--hello"]) == 0
    @test main(["--generate-config"]) == 0
end

MPI.Finalize()
