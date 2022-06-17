abstract type TagBase end

struct DataSetConfig
    name::String
    basename::String
    datagen_backend_tag::TagBase
    io_backend_tag::TagBase
    nsteps::Int32
    step_factor::Int32
    compute_seconds::Float64
    streams::Vector{DataStreamConfig}
end

mutable struct DataSet
    cfg::DataSetConfig
    curr_step::Int32
    timestamp::Float64
    streams::Vector{DataStream}
end

DataSet(cfg::DataSetConfig) = DataSet(cfg, 1, time(), Float64[])
