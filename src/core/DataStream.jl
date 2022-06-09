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

struct PayloadGroup
    range::PayloadRange
    ratio::Float64
end

PayloadGroup(range::Vector{<:Integer}, ratio::T) where {T} =
    PayloadGroup(PayloadRange(range[1], range[2]), get_ratio(ratio))

abstract type EvolutionFunction end

struct DataStreamConfig
    name::String
    evolve::EvolutionFunction
    payload_groups::Vector{PayloadGroup}
end

function get_payload_group_id(
    rank::Integer,
    nranks::Integer,
    cfg::DataStreamConfig,
)
    percentile = (rank + 1) / nranks
    current = 0.0
    for id = 1:length(cfg.payload_groups)
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
    return get_payload_group_id(MPI.Comm_rank(comm), MPI.Comm_size(comm), cfg)
end

abstract type DataObject end

mutable struct DataVector <: DataObject
    vec::Vector{Float64}
end

DataVector() = DataVector(Float64[])

mutable struct DataStream
    initial_range::PayloadRange
    range::PayloadRange
    evolve::EvolutionFunction
    data::DataObject
end

DataStream(range::PayloadRange, evolve::EvolutionFunction) =
    DataStream(range, copy(range), evolve, DataVector())

DataStream(cfg::DataStreamConfig) =
    DataStream(cfg.payload_groups[get_payload_group_id(cfg)].range, cfg.evolve)

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
    stream.range.a = round(stream.initial_range.a * growth)
    stream.range.b = round(stream.initial_range.b * growth)
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
    stream.range.a = stream.initial_range.a + growth
    stream.range.b = stream.initial_range.b + growth
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
