import MPI
import MLStyle: @match

function hello(config::Config)
    worldrank = MPI.Comm_rank(MPI.COMM_WORLD)
    worldsize = MPI.Comm_size(MPI.COMM_WORLD)
    # TODO: Should this be a command-line argument for the hello sub-command?
    backend = config[:datasets][1][:io_backend]
    basename = "hello"
    data = "Hello world, I am rank $worldrank of $worldsize\n"

    @match backend begin
        "HDF5" => hello_hdf5(data)
        "ADIOS2" => hello_adios2(data)
        "Julia" => write(basename * "_$worldrank.dat", data)
        _ => error("Unsupported I/O strategy")
    end

    MPI.Barrier(MPI.COMM_WORLD)
end

hello(filename::AbstractString) = hello(read_config(filename))

hello(::Nothing) = hello(default_config())
