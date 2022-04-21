abstract type TagBase end

########
# TODO: This should go in a helper function file
function Base.parse(::Type{Rational{Int}}, x::AbstractString)
    ms, ns = split(x, '/', keepempty = false)
    m = parse(Int, ms)
    n = parse(Int, ns)
    return m // n
end

Base.parse(::Type{Rational}, x::AbstractString) = parse(Rational{Int}, x)

function get_ratio(x::AbstractString)
    r = tryparse(Float64, x)
    return r === nothing ? convert(Float64, parse(Rational, x)) : r
end

get_ratio(x::Float64) = x
########

struct PayloadGroup
    range::NTuple{2,Int}
    ratio::Float64
end

PayloadGroup(range::Vector{<:Integer}, ratio::T) where {T} =
    PayloadGroup((range[1], range[2]), get_ratio(ratio))

struct DataStreamConfig
    name::String
    payload_groups::Vector{PayloadGroup}
end

struct DataSetConfig
    name::String
    basename::String
    datagen_backend_tag::TagBase
    io_backend_tag::TagBase
    nsteps::Int
    compute_seconds::Float64
    streams::Vector{DataStreamConfig}
end

DataSetConfig(
    name::String,
    datagen_tag::TagBase,
    io_tag::TagBase,
    nsteps::Int,
    comp_secs::Float64,
) = DataSetConfig(name, name, datagen_tag, io_tag, nsteps, comp_secs, [])

abstract type DataObject end

mutable struct DataVector <: DataObject
    vec::Vector{Float64}
end

DataVector() = DataVector(Float64[])

mutable struct DataSet
    cfg::DataSetConfig
    curr_step::Int
    timestamp::Float64
    streams::Vector{DataObject}
end

DataSet(cfg::DataSetConfig) = DataSet(cfg, 1, time(), Float64[])
