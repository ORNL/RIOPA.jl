module Ctrl

import ..Config, ..read_config, ..default_config
import ..DataSet, ..DataSetConfig, ..DataStreamConfig, ..PayloadGroup
import ..DataGen
import ..IO

function configure_stream(streamCfg::Config)
    payloads = map(
        grpCfg -> PayloadGroup(grpCfg[:size_range], grpCfg[:ratio]),
        streamCfg[:proc_payloads],
    )
    return DataStreamConfig(streamCfg[:name], payloads)
end

function configure_dataset(subCfg::Config)
    compute_seconds = get(subCfg, :compute_seconds, 0)
    datagen_tag_str = get(subCfg, :datagen_backend, nothing)
    io_tag_str = get(subCfg, :io_backend, nothing)
    streams =
        map(streamCfg -> configure_stream(streamCfg), subCfg[:data_streams])
    ds = DataSet(
        DataSetConfig(
            subCfg[:name],
            subCfg[:basename],
            DataGen.get_tag(datagen_tag_str),
            IO.get_tag(io_tag_str),
            subCfg[:nsteps],
            compute_seconds,
            streams,
        ),
    )
    DataGen.initialize_streams!(ds.cfg.datagen_backend_tag, ds)
    return ds
end

generate_data!(ds::DataSet) = DataGen.generate!(ds.cfg.datagen_backend_tag, ds)

function perform_io_step(ds::DataSet)
    IO.perform_step(ds.cfg.io_backend_tag, ds)
    ds.curr_step += 1
    ds.timestamp = time()
end

function steps_remain(ds::DataSet)
    return ds.curr_step <= ds.cfg.nsteps
end

struct Controller
    datasets::Vector{DataSet}
end

function (c::Controller)()
    cfgtimes = map(ds -> ds.cfg.compute_seconds, c.datasets)
    enabled = map(ds -> steps_remain(ds), c.datasets)
    get_reset_time = (i, enable) -> enable ? cfgtimes[i] : Inf
    times = map(((i, enable),) -> get_reset_time(i, enable), enumerate(enabled))
    while any(enabled)
        ta = time()
        dur, idx = findmin(times)
        ds = c.datasets[idx]
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
    ctrl = Controller(map(sub -> configure_dataset(sub), config[:datasets]))
    ctrl()
end

run(filename::AbstractString) = run(read_config(filename))

run(::Nothing) = run(default_config())

end
