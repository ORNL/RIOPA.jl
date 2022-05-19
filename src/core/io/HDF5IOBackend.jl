import HDF5, MPI

import RIOPA: IO

struct HDF5IOTag <: IO.IOTag end

function perform_step(::HDF5IOTag, ds::DataSet)
    worldrank = MPI.Comm_rank(MPI.COMM_WORLD)
    stepname = ds.cfg.basename * "_" * lpad(ds.curr_step, 5, '0')
    for i = 1:length(ds.streams)
        streamCfg = ds.cfg.streams[i]
        pathname = stepname * "/" * streamCfg.name
        mkpath(pathname)
        filename = "D_" * lpad(worldrank, 5, '0') * ".h5"
        HDF5.h5write(pathname * "/" * filename, "data", ds.streams[i].vec)
    end
end

IO.add("HDF5", HDF5IOTag())
