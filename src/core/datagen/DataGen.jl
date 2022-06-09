module DataGen

# Types
import RIOPA:
    TagBase,
    DataStream,
    PayloadRange,
    DataSet,
    DataVector,
    Config,
    EvolutionFunction
import OrderedCollections: LittleDict
import Polynomials: ImmutablePolynomial
# Functions
import RIOPA: get_payload_group_id
# Macros
import MLStyle: @match
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

struct GrowthFactorEvFn <: EvolutionFunction
    factor::Float64
end

GrowthFactorEvFn(params::Vector{<:Real}) = GrowthFactorEvFn(params[1])

function evolve_payload_range!(
    stream::DataStream,
    step::Integer,
    fn::GrowthFactorEvFn,
)
    growth = fn.factor^(step - 1)
    stream.range.a = stream.initial_range.a * growth
    stream.range.b = stream.initial_range.b * growth
end

struct PolynomialEvFn <: EvolutionFunction
    poly::ImmutablePolynomial
end

PolynomialEvFn(params::Vector{<:Real}) =
    PolynomialEvFn(ImmutablePolynomial(vcat(0, params)))

function evolve_payload_range!(
    stream::DataStream,
    step::Integer,
    fn::PolynomialEvFn,
)
    growth = fn.poly(step - 1)
    stream.range.a = stream.initial_range.a + growth
    stream.range.b = stream.initial_range.b + growth
end

function get_evolution_function(evcfg::Config)
    @match evcfg[:function] begin
        "GrowthFactor" => return GrowthFactorEvFn(evcfg[:params])
        "Polynomial" => return PolynomialEvFn(evcfg[:params])
        _ => @error "Unsupported stream size evolution function"
    end
end

get_evolution_function(nothing) = GrowthFactorEvFn(1.0)

function generate_stream_data!(stream::DataStream, step::Integer)
    newsize = rand((stream.range.a):(stream.range.b))
    resize!(stream.data.vec, newsize)
    Random.rand!(stream.data.vec)
    evolve_payload_range!(stream, step, stream.evolve)
end

function generate!(::DefaultDataGenTag, ds::DataSet)
    foreach(stream -> generate_stream_data!(stream, ds.curr_step), ds.streams)
end

end
