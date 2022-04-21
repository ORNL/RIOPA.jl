import MPI
import Test: @test

MPI.Init()

macro test_exists_and_rm(fn)
    return quote
        @test ispath($(esc(fn)))
        rm($(esc(fn)))
    end
end

# unit tests
include("unit/helper/test_ratios.jl")

include("unit/core/test_Ctrl.jl")
include("unit/core/test_inputs.jl")
include("unit/core/test_DataGen.jl")
include("unit/core/test_IO.jl")

include("unit/hello/test_hello.jl")

# functional tests
include("functional/test_main.jl")

# MPI.Finalize() can be called only once per run. We do it here for all
# "in-process" tests. The cmdline tests are done outside the MPI context since
# they launch other MPI tasks using system calls
MPI.Finalize()

include("functional/test_cmdline.jl")
