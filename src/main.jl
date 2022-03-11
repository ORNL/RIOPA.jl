using MPI, MLStyle

import RIOPA


function main(args)::Int32

    initialized_here = false
    if !MPI.Initialized()
        MPI.Init()
        initialized_here = true
    end

    comm = MPI.COMM_WORLD
    rank = MPI.Comm_rank(comm)
    size = MPI.Comm_size(comm)

    inputs = RIOPA.parse_inputs(args)

    configFile = inputs["config"]

    command = inputs["%COMMAND%"]
    @match command begin
        "hello" => println("Hello mode; config file: ", configFile)
        "generate-config" => RIOPA.generate_config(configFile)
        nothing => println("Normal mode; config file: ", configFile)
    end

    if initialized_here
        MPI.Finalize()
    end

    return 0

end
