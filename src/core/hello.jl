using MPI

function hello(config::Config)
    worldrank = getmpiworldrank()
    worldsize = getmpiworldsize()
    transport = config[:io][:transport]
    basename = "hello_$worldrank"
    data = "Hello world, I am rank $worldrank of $worldsize\n"
    if (transport == "HDF5")
        hello_hdf5(basename, data)
    else
        write(basename * ".dat", data)
    end
    MPI.Barrier(MPI.COMM_WORLD)
    if worldrank == 0
        println("Hello. We wrote $worldsize file(s).")
    end
end

hello(filename::AbstractString) = hello(read_config(filename))

hello(::Nothing) = hello(default_config())
