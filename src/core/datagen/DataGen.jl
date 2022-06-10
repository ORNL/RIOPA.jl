module DataGen

# Types
import RIOPA: TagBase, DataStreamConfig, DataSet, DataVector, Config
import OrderedCollections: LittleDict
# Modules
import MPI

abstract type DataGenTag <: TagBase end

function generate! end
function initialize_streams! end

tagmap = LittleDict{String,DataGenTag}()

function add(key::String, tag::DataGenTag)
    tagmap[lowercase(key)] = tag
end

function get_tag(key::String)
    try
        return tagmap[lowercase(key)]
    catch
        println("Invalid DataGen backend: ", key)
        rethrow()
    end
end

struct DefaultDataGenTag <: DataGenTag end

get_tag(::Nothing) = DefaultDataGenTag()

struct ProcessPayloadRatioError <: Exception
    msg::String
end

function check_payload_group_ratios(ds::DataSet)
    for stream_cfg in ds.cfg.streams
        sum = 0.0
        for grp in stream_cfg.payload_groups
            sum += grp.ratio
        end
        if !isapprox(sum, 1.0)
            throw(
                ProcessPayloadRatioError(
                    "Sum of payload group ratios ($sum) must equal 1" *
                    "; dataset: " *
                    ds.cfg.name *
                    ", stream: " *
                    stream_cfg.name,
                ),
            )
        end
    end
end

function initialize_streams!(::DefaultDataGenTag, ds::DataSet)
    check_payload_group_ratios(ds)
    ds.streams = map(_ -> DataVector(), ds.cfg.streams)
end

function get_payload_group_id(
    rank::Integer,
    nranks::Integer,
    cfg::DataStreamConfig,
)
    percentile = (rank + 1) / nranks
    current = 0.0
    for id in eachindex(cfg.payload_groups)
        grp = cfg.payload_groups[id]
        current += grp.ratio
        if percentile <= current
            return id
        end
    end
    # TODO: throw an error here ?
end

function get_payload_group_id(cfg::DataStreamConfig)
    comm = MPI.COMM_WORLD
    get_payload_group_id(MPI.Comm_rank(comm), MPI.Comm_size(comm), cfg)
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
        ((i, stream_cfg),) -> generate_stream_data!(ds.streams[i], stream_cfg),
        enumerate(ds.cfg.streams),
    )
end

end
