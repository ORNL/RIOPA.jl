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

include(joinpath("helper", "Ratios.jl"))

include(joinpath("core", "Config.jl"))
include(joinpath("core", "Args.jl"))
include(joinpath("core", "DataStream.jl"))
include(joinpath("core", "DataSet.jl"))
include(joinpath("core", "datagen", "DataGen.jl"))
include(joinpath("core", "io", "IO.jl"))
include(joinpath("core", "Ctrl.jl"))

include(joinpath("core", "io", "HDF5Backend.jl"))
include(joinpath("core", "io", "IOStreamBackend.jl"))

# include(joinpath("hello", "adios2.jl"))
include(joinpath("hello", "hdf5.jl"))
include(joinpath("hello", "hello.jl"))

import MLStyle: @match

function main(args)::Int32
    inputs = RIOPA.parse_inputs(args)

    config_filename = inputs["config"]

    command = inputs["%COMMAND%"]
    @match command begin
        "hello" => RIOPA.hello(config_filename)
        "generate-config" => RIOPA.generate_config(config_filename)
        nothing => RIOPA.Ctrl.run(config_filename)
    end

    return 0
end

end
