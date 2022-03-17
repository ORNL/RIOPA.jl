import MPI

MPI.Init()

# unit tests
include("unit/core/test_inputs.jl")
include("unit/core/test_hello.jl")

# functional tests
include("functional/test_main.jl")

# MPI.Finalize() can be called only once per run. We do it here for all
# "in-process" tests. The cmdline tests are done outside the MPI context since
# they launch other MPI tasks using system calls
MPI.Finalize()

include("functional/test_cmdline.jl")
