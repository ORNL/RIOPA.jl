using MPI
import MLStyle: @match

function hello(config::Config)
    worldrank = getmpiworldrank()
    worldsize = getmpiworldsize()
    transport = config[:datasets][1][:transport]
    basename = "hello"
    data = "Hello world, I am rank $worldrank of $worldsize\n"

    @match transport begin
        "HDF5" => hello_hdf5(data)
        "ADIOS2" => hello_adios2(data)
        "Julia" => write(basename * ".dat", data)
        _ => @error "Unsupported transport strategy"
    end

    MPI.Barrier(MPI.COMM_WORLD)
end

hello(filename::AbstractString) = hello(read_config(filename))

hello(::Nothing) = hello(default_config())
