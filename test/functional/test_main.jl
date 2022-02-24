
using Test, MPI

@testset "test_main" begin


    @test run(Cmd(`mpiexec -n 4 julia --project=. src/riopa.jl hello`)).exitcode == 0

    # @test println(status)
end

# @testset "test_main_failure" begin
#     @test main(["hello-adios2"]) == 0
# end

