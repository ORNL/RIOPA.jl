module Ctrl

import ..Config
import ..read_config
import ..default_config

abstract type TagBase end
function generate_data! end
function perform_io_step end

struct DataSetConfig
    name::String
    datagen_backend_tag::TagBase
    io_backend_tag::TagBase
    nsteps::Int
    compute_seconds::Float64
end

mutable struct DataSet
    cfg::DataSetConfig
    curr_step::Int
    timestamp::Float64
    data::Vector{Float64}
end

DataSet(cfg::DataSetConfig) = DataSet(cfg, 1, time(), Float64[])

function configure_dataset(subCfg::Config)
    compute_seconds = get(subCfg, :compute_seconds, 0.001)
    return DataSet(
        DataSetConfig(subCfg[:name], subCfg[:nsteps], compute_seconds),
    )
end

generate_data!(ds::DataSet) = generate_data!(ds.cfg.datagen_backend_tag, ds)

function perform_io_step(ds::DataSet)
    perform_io_step(ds.cfg.io_backend_tag, ds)
    ds.curr_step += 1
    ds.timestamp = time()
end

function steps_remain(ds::DataSet)
    return ds.curr_step <= ds.cfg.nsteps
end

function run_internal(datasets::Vector{DataSet})
    cfgtimes = map(ds -> ds.cfg.compute_seconds, datasets)
    enabled = map(ds -> steps_remain(ds), datasets)
    get_reset_time = (i, enable) -> enable ? cfgtimes[i] : Inf
    times = map(((i, enable),) -> get_reset_time(i, enable), enumerate(enabled))
    while any(enabled)
        ta = time()
        dur, idx = findmin(times)
        ds = datasets[idx]
        generate_data!(ds)
        diff = time() - ta
        dur = max(0, dur - diff)
        sleep(dur)
        times .-= dur
        perform_io_step(ds)
        enabled[idx] = steps_remain(ds)
        times[idx] = get_reset_time(idx, enabled[idx])
    end
end

function run(config::Config)
    datasets = map(sub -> configure_dataset(sub), config[:datasets])
    run_internal(datasets)
end

run(filename::AbstractString) = run(read_config(filename))

run(::Nothing) = run(default_config())

end
