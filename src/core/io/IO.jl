module IO

# Types
import RIOPA: TagBase, DataSet
import OrderedCollections: LittleDict

abstract type IOTag <: TagBase end

function write_data_object end
function perform_step end

tagmap = LittleDict{String,IOTag}()

function add(key::String, tag::IOTag)
    tagmap[key] = tag
end

function get_tag(key::String)
    try
        return tagmap[key]
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
