import MPI

import RIOPA: IO

struct IOStreamTag <: IO.IOTag end

function IO.write_data_object(
    ::IOStreamTag,
    pathname::AbstractString,
    data::DataObject,
)
    worldrank = MPI.Comm_rank(MPI.COMM_WORLD)
    filename = "D_" * lpad(worldrank, 5, '0') * ".dat"
    write(pathname * "/" * filename, "data", data.vec)
end

function IO.perform_step(::IOStreamTag, ds::DataSet)
    stepname = ds.cfg.basename * "_" * lpad(ds.curr_step, 5, '0')
    for i in eachindex(ds.streams)
        stream_cfg = ds.cfg.streams[i]
        pathname = stepname * "/" * stream_cfg.name
        mkpath(pathname)
        IO.write_data_object(iotag, pathname, ds.streams[i])
    end
end

IO.add("IOStream", IOStreamTag())
