module RIOPA

export parse_inputs, read_config, generate_config

import MPI

function __init__()
    # - Initialize here instead of main so that the MPI context can be available
    # for tests.
    # - Conditional allows for case when external users (or tests) have already
    # initialized an MPI context.
    if !MPI.Initialized()
        MPI.Init()
    end
end

getmpiworldrank() = MPI.Comm_rank(MPI.COMM_WORLD)
getmpiworldsize() = MPI.Comm_size(MPI.COMM_WORLD)

include("core/inputs.jl")
include("core/hello.jl")

include("core/transport/hdf5.jl")

end
