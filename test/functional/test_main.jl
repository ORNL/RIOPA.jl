
using Test, MPI, ArgParse

MPI.Init()

include("../../src/main.jl")
# These tests just make sure 
@testset "test_main" begin
    # mpiexec() do cmd
        # @test run(Cmd(`$cmd -n 4 julia --project=. src/main/riopa.jl hello`)).exitcode == 0
        @test main(["--hello"]) == 0
        @test_throws ArgParse.ArgParseError("unrecognized option --hello-fail") main(["--hello-fail"])
    # end
end

MPI.Finalize()
