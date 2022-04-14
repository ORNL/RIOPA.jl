module IO

import ..TagBase, ..DataSet
import OrderedCollections: LittleDict

abstract type IOTag <: TagBase end

function perform_step end

tagmap = LittleDict{String,IOTag}()

function add(key::String, tag::IOTag)
    tagmap[key] = tag
end

function get_tag(key::String)
    # TODO: check for key ?
    return tagmap[key]
end

struct DefaultIOTag <: IOTag end

get_tag(::Nothing) = DefaultIOTag()

function perform_step(::DefaultIOTag, ::DataSet)
    # error ?
end

import HDF5, MPI

struct HDF5IOTag <: IOTag end
add("HDF5", HDF5IOTag())

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

end
