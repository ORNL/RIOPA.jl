
import MPI
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

    if inputs["generate-config"]
        # Generate config.yaml
    else
        if inputs["hello"]
            # Run hello mode
        else
            # Run normal mode
        end
    end

    if initialized_here
        MPI.Finalize()
    end

    return 0

end
