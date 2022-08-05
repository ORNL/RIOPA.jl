# Functions
import Polynomials: ImmutablePolynomial
# Macros
import MLStyle: @match
# Modules
import MPI

mutable struct PayloadRange
    a::Int32
    b::Int32
end

# PayloadRange(r::NTuple{2,<:Integer}) = PayloadRange(r[1], r[2])

function Base.copy(r::PayloadRange)
    return PayloadRange(r.a, r.b)
end

function Base.:(==)(r::PayloadRange, t::NTuple{2,<:Integer})
    return r.a == t[1] && r.b == t[2]
end

function Base.:(*)(r::PayloadRange, x::Real)
    return PayloadRange(r.a * x, r.b * x)
end

struct PayloadGroup
    size_ratio::Float64
    proc_ratio::Float64
end

# PayloadGroup(range::Vector{<:Integer}, ratio::T) where {T} =
#     PayloadGroup(PayloadRange(range[1], range[2]), get_ratio(ratio))
PayloadGroup(size_ratio, proc_ratio) =
    PayloadGroup(get_ratio(size_ratio), get_ratio(proc_ratio))

abstract type EvolutionFunction end

struct DataStreamConfig
    name::String
    initial_size_range::PayloadRange
    evolve::EvolutionFunction
    payload_groups::Vector{PayloadGroup}
end

DataStreamConfig(name::String, range::Vector{<:Integer},
                 evolve::EvolutionFunction, groups::Vector{PayloadGroup}) =
DataStreamConfig(name, PayloadRange(range[1], range[2]), evolve, groups)

function get_payload_group_id(
    rank::Integer,
    nranks::Integer,
    cfg::DataStreamConfig,
)
    percentile = (rank + 1) / nranks
    current = 0.0
    for id = 1:length(cfg.payload_groups)
        grp = cfg.payload_groups[id]
        current += grp.proc_ratio
        if percentile <= current
            return id
        end
    end
    # TODO: throw an error here ?
end

function get_payload_group_id(cfg::DataStreamConfig)
    comm = MPI.COMM_WORLD
    return get_payload_group_id(MPI.Comm_rank(comm), MPI.Comm_size(comm), cfg)
end

abstract type DataObject end

mutable struct DataVector <: DataObject
    vec::Vector{Int8}
end

DataVector() = DataVector(Int8[])

mutable struct DataStream
    initial_range::PayloadRange
    size_ratio::Float64
    range::PayloadRange
    evolve::EvolutionFunction
    data::DataObject
end

# DataStream(range::PayloadRange, evolve::EvolutionFunction) =
#     DataStream(range, copy(range), evolve, DataVector())
DataStream(initrange::PayloadRange, ratio::Float64, evolve::EvolutionFunction) =
    DataStream(initrange, ratio, initrange * ratio, evolve, DataVector())

DataStream(cfg::DataStreamConfig) = DataStream(
    cfg.initial_size_range,
    cfg.payload_groups[get_payload_group_id(cfg)].size_ratio,
    cfg.evolve,
)

struct GrowthFactorEvFn <: EvolutionFunction
    factor::Float64
end

GrowthFactorEvFn(params::Vector{<:Real}) = GrowthFactorEvFn(params[1])

function evolve_payload_range!(
    stream::DataStream,
    step::Integer,
    fn::GrowthFactorEvFn,
)
    growth = fn.factor^step
    stream.range.a = round(stream.initial_range.a * growth * stream.size_ratio)
    stream.range.b = round(stream.initial_range.b * growth * stream.size_ratio)
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
    growth = fn.poly(step)
    stream.range.a = round((stream.initial_range.a + growth) * stream.size_ratio)
    stream.range.b = round((stream.initial_range.b + growth) * stream.size_ratio)
end

function evolve_payload_range!(stream::DataStream, step::Integer)
    evolve_payload_range!(stream, step, stream.evolve)
end

function check_length(expected::Integer, params::Vector{<:Real})
    if length(params) != expected
        @error "Wrong number of parameters"
    end
    return params
end

function get_evolution_function(evcfg::Config)
    params = evcfg[:params]
    @match evcfg[:function] begin
        "GrowthFactor" => return GrowthFactorEvFn(check_length(1, params))
        "Polynomial" => return PolynomialEvFn(params)
        "Linear" => return PolynomialEvFn(check_length(1, params))
        _ => @error "Unsupported stream size evolution function"
    end
end

get_evolution_function(nothing) = GrowthFactorEvFn(1.0)
