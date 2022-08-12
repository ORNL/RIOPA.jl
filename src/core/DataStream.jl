# Functions
import Polynomials: ImmutablePolynomial
# Macros
import MLStyle: @match
# Modules
import MPI

mutable struct PayloadRange
    a::Int32
    b::Int32
    PayloadRange(a::Real, b::Real) = new(floor(a), ceil(b))
end

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
    PayloadGroup(size_ratio, proc_ratio) =
        new(get_ratio(size_ratio), get_ratio(proc_ratio))
end

abstract type EvolutionFunction end

struct DataStreamConfig
    name::String
    initial_size_range::PayloadRange
    evolve::EvolutionFunction
    payload_groups::Vector{PayloadGroup}
end

DataStreamConfig(
    name::String,
    range::Vector{<:Integer},
    evolve::EvolutionFunction,
    groups::Vector{PayloadGroup},
) = DataStreamConfig(name, PayloadRange(range[1], range[2]), evolve, groups)

struct ProcessGroupRatioError <: Exception
    msg::String
end

function check_payload_group_ratios(
    stream_cfg::DataStreamConfig,
    dsname::AbstractString,
    get_ratio,
)
    sum = 0.0
    for grp in stream_cfg.payload_groups
        sum += get_ratio(grp)
    end
    if !isapprox(sum, 1.0)
        throw(
            ProcessGroupRatioError(
                "Sum of ratios ($sum) must equal 1; dataset: " *
                dsname *
                ", stream: " *
                stream_cfg.name,
            ),
        )
    end
end

function check_payload_group_ratios(
    stream_cfg::DataStreamConfig,
    dsname::AbstractString,
)
    check_payload_group_ratios(
        stream_cfg,
        dsname,
        grp::PayloadGroup -> grp.size_ratio,
    )
    check_payload_group_ratios(
        stream_cfg,
        dsname,
        grp::PayloadGroup -> grp.proc_ratio,
    )
end

function get_payload_group_id_and_size(
    rank::Integer,
    nranks::Integer,
    cfg::DataStreamConfig,
)
    percentile = (rank + 1) / nranks
    current = 0.0
    for id = 1:length(cfg.payload_groups)
        grp = cfg.payload_groups[id]
        prev = current
        current += grp.proc_ratio
        if percentile <= current
            size = floor(Int32, current * nranks - floor(prev * nranks))
            return id, size
        end
    end
    # TODO: throw an error here ?
end

function get_payload_group_id_and_size(cfg::DataStreamConfig)
    comm = MPI.COMM_WORLD
    return get_payload_group_id_and_size(
        MPI.Comm_rank(comm),
        MPI.Comm_size(comm),
        cfg,
    )
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

DataStream(initrange::PayloadRange, ratio::Float64, evolve::EvolutionFunction) =
    DataStream(initrange, ratio, initrange * ratio, evolve, DataVector())

function DataStream(cfg::DataStreamConfig)
    group_id, group_size = get_payload_group_id_and_size(cfg)
    group = cfg.payload_groups[group_id]
    size_ratio = group.size_ratio / group_size
    return DataStream(cfg.initial_size_range, size_ratio, cfg.evolve)
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
    stream.range.a =
        round((stream.initial_range.a + growth) * stream.size_ratio)
    stream.range.b =
        round((stream.initial_range.b + growth) * stream.size_ratio)
end

function evolve_payload_range!(stream::DataStream, step::Integer)
    evolve_payload_range!(stream, step, stream.evolve)
end

function check_length(expected::Integer, params::Vector{<:Real})
    if length(params) != expected
        error("Wrong number of parameters")
    end
    return params
end

function get_evolution_function(evcfg::Config)
    params = evcfg[:params]
    @match evcfg[:function] begin
        "GrowthFactor" => return GrowthFactorEvFn(check_length(1, params))
        "Polynomial" => return PolynomialEvFn(params)
        "Linear" => return PolynomialEvFn(check_length(1, params))
        _ => error("Unsupported stream size evolution function")
    end
end

get_evolution_function(nothing) = GrowthFactorEvFn(1.0)
