import MPI
import Test: @testset, @test, @test_throws

@testset "cmdline" begin
    MPI.mpiexec() do runcmd
        juliacmd = `julia --project=.`

        @test run(`$runcmd -n 4 $juliacmd riopa.jl hello`).exitcode == 0
        for i = 0:3
            filename = "hello_$i.dat"
            @test ispath(filename)
            rm(filename)
        end

        @test run(
            `$runcmd -n 4 $juliacmd riopa.jl generate-config`,
        ).exitcode == 0
        @test ispath("default.yaml")
        rm("default.yaml")
    end
end
