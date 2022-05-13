module RIOPA

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

include("helper/Ratios.jl")

include("core/Config.jl")
include("core/Args.jl")
include("core/DataSet.jl")
include("core/datagen/DataGen.jl")
include("core/io/IO.jl")
include("core/Ctrl.jl")

include("core/io/HDF5IOBackend.jl")

# include("hello/adios2.jl")
include("hello/hdf5.jl")
include("hello/hello.jl")

end
