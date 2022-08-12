module DataGen

# Types
import RIOPA: TagBase, DataStream, PayloadRange, DataSet
import OrderedCollections: LittleDict
# Functions
import RIOPA: check_payload_group_ratios, evolve_payload_range!
# Modules
import MPI, Random

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

function check_payload_group_ratios(ds::DataSet)
    for stream_cfg in ds.cfg.streams
        check_payload_group_ratios(stream_cfg, ds.cfg.name)
    end
end

function initialize_streams!(::DefaultDataGenTag, ds::DataSet)
    check_payload_group_ratios(ds)
    ds.streams = map(stream_cfg -> DataStream(stream_cfg), ds.cfg.streams)
end

function generate_stream_data!(
    stream::DataStream,
    step::Integer,
    step_factor::Integer,
)
    newsize = rand((stream.range.a):(stream.range.b))
    resize!(stream.data.vec, newsize)
    Random.rand!(stream.data.vec)
    evolve_payload_range!(stream, step * step_factor)
end

function generate!(::DefaultDataGenTag, ds::DataSet)
    foreach(
        stream ->
            generate_stream_data!(stream, ds.curr_step, ds.cfg.step_factor),
        ds.streams,
    )
end

end
