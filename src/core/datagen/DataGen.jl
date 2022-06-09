module DataGen

# Types
import RIOPA:
    TagBase,
    DataStream,
    PayloadRange,
    DataSet
import OrderedCollections: LittleDict
# Functions
import RIOPA: evolve_payload_range!
# Modules
import MPI, Random

abstract type DataGenTag <: TagBase end

function generate! end
function initialize_streams! end

tagmap = LittleDict{String,DataGenTag}()

function add(key::String, tag::DataGenTag)
    tagmap[key] = tag
end

function get_tag(key::String)
    try
        return tagmap[key]
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
    ds.streams = map(stream_cfg -> DataStream(stream_cfg), ds.cfg.streams)
end

function generate_stream_data!(stream::DataStream, step::Integer)
    newsize = rand((stream.range.a):(stream.range.b))
    resize!(stream.data.vec, newsize)
    Random.rand!(stream.data.vec)
    evolve_payload_range!(stream, step)
end

function generate!(::DefaultDataGenTag, ds::DataSet)
    foreach(stream -> generate_stream_data!(stream, ds.curr_step), ds.streams)
end

end
