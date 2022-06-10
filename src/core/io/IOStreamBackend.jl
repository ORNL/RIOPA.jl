import MPI

import RIOPA: IO

struct IOStreamTag <: IO.IOTag end

function IO.perform_step(::IOStreamTag, ds::DataSet)
    worldrank = MPI.Comm_rank(MPI.COMM_WORLD)
    stepname = ds.cfg.basename * "_" * lpad(ds.curr_step, 5, '0')
    for i in eachindex(ds.streams)
        stream_cfg = ds.cfg.streams[i]
        pathname = stepname * "/" * stream_cfg.name
        mkpath(pathname)
        filename = "D_" * lpad(worldrank, 5, '0') * ".dat"
        write(pathname * "/" * filename, ds.streams[i].vec)
    end
end

IO.add("IOStream", IOStreamTag())
