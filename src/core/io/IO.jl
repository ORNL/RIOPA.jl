module IO

# Types
import RIOPA: TagBase, DataSet
import OrderedCollections: LittleDict

abstract type IOTag <: TagBase end

function write_data_object end

function perform_step(iotag::IOTag, ds::DataSet)
    stepname = ds.cfg.basename * "_" * lpad(ds.curr_step, 5, '0')
    for i in eachindex(ds.streams)
        stream_cfg = ds.cfg.streams[i]
        pathname = stepname * "/" * stream_cfg.name
        mkpath(pathname)
        write_data_object(iotag, pathname, ds.streams[i].data)
    end
end

tagmap = LittleDict{String,IOTag}()

function add(key::String, tag::IOTag)
    tagmap[lowercase(key)] = tag
end

function get_tag(key::String)
    try
        return tagmap[lowercase(key)]
    catch
        println("Invalid IO backend: ", key)
        rethrow()
    end
end

struct DefaultIOTag <: IOTag end

get_tag(::Nothing) = DefaultIOTag()

function perform_step(::DefaultIOTag, ::DataSet)
    # error ?
end

end
