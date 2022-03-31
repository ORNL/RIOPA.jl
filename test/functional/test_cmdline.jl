import MPI
import Test: @testset, @test, @test_throws

@testset "cmdline" begin
    MPI.mpiexec() do runcmd
        juliacmd = `julia --project=.`

        @test run(`$runcmd -n 4 $juliacmd riopa.jl hello`).exitcode == 0
        for i = 0:3
            @test_exists_and_rm("hello_$i.h5")
        end

        @test run(
            `$runcmd -n 4 $juliacmd riopa.jl generate-config`,
        ).exitcode == 0
        @test_exists_and_rm("default.yaml")
    end
end
