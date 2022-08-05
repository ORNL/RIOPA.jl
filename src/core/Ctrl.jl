module Ctrl

# Types
import RIOPA: Config, DataSet, DataSetConfig, DataStreamConfig, PayloadGroup
# Functions
import RIOPA: read_config, default_config, get_evolution_function
# Modules
import RIOPA: DataGen, IO

function configure_stream(stream_cfg::Config)
    evolve_func = get_evolution_function(get(stream_cfg, :evolution, nothing))
    groups = map(
        grp_cfg -> PayloadGroup(grp_cfg[:size_ratio], grp_cfg[:proc_ratio]),
        stream_cfg[:proc_payload_groups],
    )
    return DataStreamConfig(
        stream_cfg[:name],
        stream_cfg[:initial_size_range],
        evolve_func,
        groups,
    )
end

function configure_dataset(sub_cfg::Config)
    compute_seconds = get(sub_cfg, :compute_seconds, 0)
    datagen_tag_str = get(sub_cfg, :datagen_backend, nothing)
    io_tag_str = get(sub_cfg, :io_backend, nothing)
    step_factor = get(sub_cfg, :step_conversion_factor, 1)
    streams = map(configure_stream, sub_cfg[:data_streams])
    ds = DataSet(
        DataSetConfig(
            sub_cfg[:name],
            sub_cfg[:basename],
            DataGen.get_tag(datagen_tag_str),
            IO.get_tag(io_tag_str),
            sub_cfg[:nsteps],
            step_factor,
            compute_seconds,
            streams,
        ),
    )
    DataGen.initialize_streams!(ds.cfg.datagen_backend_tag, ds)
    return ds
end

generate_data!(ds::DataSet) = DataGen.generate!(ds.cfg.datagen_backend_tag, ds)

function perform_io_step!(ds::DataSet)
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
    enabled = map(steps_remain, c.datasets)
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
        perform_io_step!(ds)
        enabled[idx] = steps_remain(ds)
        times[idx] = get_reset_time(idx, enabled[idx])
    end
end

function run(config::Config)
    ctrl = Controller(map(configure_dataset, config[:datasets]))
    ctrl()
end

run(filename::AbstractString) = run(read_config(filename))

run(::Nothing) = run(default_config())

end
