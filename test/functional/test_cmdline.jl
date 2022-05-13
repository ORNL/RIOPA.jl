import MPI, HDF5
import Test: @testset, @test, @test_throws

@testset "cmdline" begin
    MPI.mpiexec() do runcmd
        juliacmd = `julia --project=.`

        @test run(`$runcmd -n 4 $juliacmd riopa.jl hello`).exitcode == 0
        if HDF5.has_parallel()
            @test_exists_and_rm("hello.h5")
        else
            for i = 0:3
                @test_exists_and_rm("hello_$i.h5")
            end
        end

        @test run(`$runcmd -n 4 $juliacmd riopa.jl generate-config`).exitcode ==
              0
        @test_exists_and_rm("riopa_default.yaml")
    end
end
