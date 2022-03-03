
import MPI
import RIOPA


function main(args)::Int32

    MPI.Init()

    comm = MPI.COMM_WORLD
    rank = MPI.Comm_rank(comm)
    size = MPI.Comm_size(comm)

    try

        inputs::RIOPA.Inputs = RIOPA.parse_inputs(args)

    catch y

        if rank == 0
            println(y)
            messageHelp = string(raw"
    RIOPA usage: 
      $ mpirun -n nprocs julia --project=path-to-RIOPA riopa.jl arg1
      where:
          nprocs: number of MPI processes
          arg1: 
            - a config yaml file to generate I/O: config.yaml
            - hello mode: [hello, hello-adios2, hello-hdf5]
      ")
            println(messageHelp)
        end
    end

    MPI.Finalize()

    return 0

end

