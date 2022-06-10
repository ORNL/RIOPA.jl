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

function IO.perform_step(iotag::HDF5IOTag, ds::DataSet)
    stepname = ds.cfg.basename * "_" * lpad(ds.curr_step, 5, '0')
    for i in eachindex(ds.streams)
        stream_cfg = ds.cfg.streams[i]
        pathname = stepname * "/" * stream_cfg.name
        mkpath(pathname)
        IO.write_data_object(iotag, pathname, ds.streams[i])
    end
end

IO.add("HDF5", HDF5IOTag())
