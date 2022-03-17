
# it should use parallel-HDF5
import HDF5

function hello_hdf5(basename::AbstractString, data::AbstractString)
    HDF5.h5write(basename * ".h5", "hello/data", data)
end
