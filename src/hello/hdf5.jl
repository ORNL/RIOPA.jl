
# to use parallel HDF5:
# Set JULIA_HDF5_PATH to directory containing the parallel version
# Then rebuild the HDF5 package
import HDF5, MPI

function hello_hdf5(data::AbstractString)
    basename = "hello"
    comm = MPI.COMM_WORLD
    rank = MPI.Comm_rank(comm)
    nranks = MPI.Comm_size(comm)
    if HDF5.has_parallel()
        info = MPI.Info()
        HDF5.h5open(basename * ".h5", "w", comm, info) do file
            grp = HDF5.create_group(file, "hello")
            dset = HDF5.create_dataset(
                grp,
                "data",
                HDF5.datatype(Int64),
                HDF5.dataspace(2, nranks),
                chunk = (2, 1),
                dxpl_mpio = :collective,
            )
            dset[:, rank+1] = [rank, nranks]
        end
    else
        HDF5.h5write(basename * "_$rank.h5", "hello/data", data)
    end
end
