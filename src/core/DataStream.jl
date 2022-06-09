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
    range::PayloadRange
    initial_range::PayloadRange
    evolve::EvolutionFunction
    data::DataObject
end

DataStream(range::PayloadRange, evolve::EvolutionFunction) =
    DataStream(range, copy(range), evolve, DataVector())

DataStream(cfg::DataStreamConfig) =
    DataStream(cfg.payload_groups[get_payload_group_id(cfg)].range, cfg.evolve)
