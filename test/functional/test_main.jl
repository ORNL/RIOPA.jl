
using Test, MPI

# These tests just make sure 
@testset "test_main" begin
    mpiexec() do cmd
        @test run(Cmd(`$cmd -n 4 julia --project=. src/main/riopa.jl hello`)).exitcode == 0
    end
end
