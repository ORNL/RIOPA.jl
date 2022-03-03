
using Test, MPI

# These tests just make sure 
@testset "test_main" begin
    @test run(Cmd(`mpiexec -n 4 julia --project=. src/main/riopa.jl hello`)).exitcode == 0
end
