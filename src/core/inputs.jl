
mutable struct Inputs
    hello::String

    Inputs() = new("")
end


function InputsParser(args)::Inputs

    messageHelp = string(raw"
RIOPA usage: 
  $ mpirun -n nprocs julia --project=path-to-RIOPA riopa.jl arg1
  where:
      nprocs: number of MPI processes
      arg1: 
        - a config yaml file to generate I/O: config.yaml
        - hello mode: [hello, hello-adios2, hello-hdf5]
  ")

    inputs = Inputs()

    if size(args)[1] == 1

        arg1::String = args[1]

        if arg1 == "hello" || arg1 == "hello-adios2"
            inputs.hello = arg1
        else
            message = string("RIOPA: input argument ", arg1, " is not valid ", messageHelp)
            throw(ArgumentError(message))
        end
    else
        message = string("RIOPA: input arguments are not valid\n", messageHelp)
        throw(ArgumentError(message))
    end

    return inputs
end
