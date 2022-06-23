import HDF5, MPI

import RIOPA: IO

struct HDF5IOTag <: IO.IOTag end

function IO.write_data_object(
    ::HDF5IOTag,
    pathname::AbstractString,
    data::DataObject,
)
    worldrank = MPI.Comm_rank(MPI.COMM_WORLD)
    filename = "D_" * lpad(worldrank, 5, '0') * ".h5"
    HDF5.h5write(pathname * "/" * filename, "data", data.vec)
end

IO.add("HDF5", HDF5IOTag())
