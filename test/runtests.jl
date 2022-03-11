
using MPI

MPI.Init()

# unit tests
include("unit/core/test_inputs.jl")


# functional tests
include("functional/test_main.jl")

MPI.Finalize()

include("functional/test_cmdline.jl")
