module DataGen

import ..TagBase, ..DataStreamConfig, ..DataSet, ..DataVector
import ..Config
import OrderedCollections: LittleDict
import MPI

abstract type DataGenTag <: TagBase end

function generate! end
function initialize_streams! end

tagmap = LittleDict{String,DataGenTag}()

function add(key::String, tag::DataGenTag)
    tagmap[key] = tag
end

function get_tag(key::String)
    # TODO: check for key ?
    return tagmap[key]
end

struct DefaultDataGenTag <: DataGenTag end

get_tag(::Nothing) = DefaultDataGenTag()

function initialize_streams!(::DefaultDataGenTag, ds::DataSet)
    ds.streams = map(streamCfg -> DataVector(), ds.cfg.streams)
    # TODO: check sum of ratios == 1.0
end

function get_payload_group_id(cfg::DataStreamConfig)
    worldrank = MPI.Comm_rank(MPI.COMM_WORLD)
    worldsize = MPI.Comm_size(MPI.COMM_WORLD)
    percentile = (worldrank + 1) / worldsize
    current = 0.0
    for id = 1:length(cfg.payload_groups)
        grp = cfg.payload_groups[id]
        current += grp.ratio
        if percentile <= current
            return id
        end
    end
    # throw an error
end

function generate_stream_data!(data::DataVector, cfg::DataStreamConfig)
    grpid = get_payload_group_id(cfg)
    grp = cfg.payload_groups[grpid]
    size = rand(grp.range[1]:grp.range[2])
    empty!(data.vec)
    sizehint!(data.vec, size)
    # TODO: might be performing an avoidable copy
    append!(data.vec, rand(Float64, size))
end

function generate!(::DefaultDataGenTag, ds::DataSet)
    # generate data at each stream for current MPI rank
    foreach(
        ((i, streamCfg),) -> generate_stream_data!(ds.streams[i], streamCfg),
        enumerate(ds.cfg.streams),
    )
end

end
