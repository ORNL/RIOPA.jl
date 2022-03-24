using MPI
import MLStyle: @match

function hello(config::Config)
    worldrank = getmpiworldrank()
    worldsize = getmpiworldsize()
    transport = config[:io][:transport]
    basename = "hello_$worldrank"
    data = "Hello world, I am rank $worldrank of $worldsize\n"

    @match transport begin
        "HDF5" => hello_hdf5(basename, data)
        "ADIOS2" => hello_adios2(basename, data)
        "Julia" => write(basename * ".dat", data)
        _ => @error "Unsupported transport strategy"
    end

    MPI.Barrier(MPI.COMM_WORLD)
    if worldrank == 0
        println("Hello. We wrote $worldsize file(s).")
    end
end

hello(filename::AbstractString) = hello(read_config(filename))

hello(::Nothing) = hello(default_config())
