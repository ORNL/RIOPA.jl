abstract type TagBase end

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
