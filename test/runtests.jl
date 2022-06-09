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
include(joinpath("unit", "helper", "test_ratios.jl"))

include(joinpath("unit", "core", "test_Args.jl"))
include(joinpath("unit", "core", "test_Config.jl"))
include(joinpath("unit", "core", "test_Ctrl.jl"))
include(joinpath("unit", "core", "test_DataStream.jl"))
include(joinpath("unit", "core", "test_DataGen.jl"))
include(joinpath("unit", "core", "test_IO.jl"))

include(joinpath("unit", "hello", "test_hello.jl"))

# functional tests
include(joinpath("functional", "test_main.jl"))

# MPI.Finalize() can be called only once per run. We do it here for all
# "in-process" tests. The cmdline tests are done outside the MPI context since
# they launch other MPI tasks using system calls
MPI.Finalize()

include(joinpath("functional", "test_cmdline.jl"))
