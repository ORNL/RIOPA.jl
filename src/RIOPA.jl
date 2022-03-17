module RIOPA

export parse_inputs, read_config, generate_config

import MPI

function __init__()
    if !MPI.Initialized()
        MPI.Init()
    end
end

getmpiworldrank() = MPI.Comm_rank(MPI.COMM_WORLD)
getmpiworldsize() = MPI.Comm_size(MPI.COMM_WORLD)

include("core/inputs.jl")

end
