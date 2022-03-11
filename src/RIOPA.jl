module RIOPA

export parse_inputs, read_config, generate_config

import MPI

const worldrank = Ref{Int}(-1)
function __init__()
    if !MPI.Initialized()
        MPI.Init()
    end
    worldrank[] = MPI.Comm_rank(MPI.COMM_WORLD)
end

include("core/inputs.jl")

end
