import YAML, MPI, OrderedCollections

function default_config_filename()
    return "riopa_default.yaml"
end

const Config = OrderedCollections.LittleDict{Symbol,Any}

function read_config(filename::AbstractString = default_config_filename())
    return YAML.load_file(filename, dicttype = Config)
end

read_config(::Nothing) = read_config()

function default_config()
    D = Config
    config = D(
        :datasets => [
            D(
                :type => "output",
                :name => "data 1",
                :basename => "data_one",
                :io_backend => "HDF5",
                :nsteps => 10,
                :step_conversion_factor => 10,
                :compute_seconds => 1.0,
                :data_streams => [
                    D(
                        :name => "Level_0",
                        :initial_size_range => [3000, 3600],
                        :evolution => D(
                            :function => "GrowthFactor",
                            :params => [1.0718],
                        ),
                        :proc_payload_groups => [
                            D(:size_ratio => "1/3", :proc_ratio => 0.5),
                            D(:size_ratio => "2/3", :proc_ratio => 0.5),
                        ],
                    ),
                    D(
                        :name => "Level_1",
                        :initial_size_range => [6000, 7200],
                        :evolution => D(
                            :function => "GrowthFactor",
                            :params => [1.0414],
                        ),
                        :proc_payload_groups => [
                            D(:size_ratio => "1/3", :proc_ratio => "1/4"),
                            D(:size_ratio => "2/3", :proc_ratio => "3/4"),
                        ],
                    ),
                ],
            ),
            D(
                :type => "output",
                :name => "data 2",
                :io_backend => "IOStream",
                :basename => "data_two",
                :nsteps => 3,
                :step_conversion_factor => 30,
                :compute_seconds => 3.0,
                :data_streams => [
                    D(
                        :name => "Level_0",
                        :initial_size_range => [3000, 3600],
                        :proc_payload_groups => [
                            D(:size_ratio => "1/3", :proc_ratio => 0.1),
                            D(:size_ratio => "2/3", :proc_ratio => 0.9),
                        ],
                    ),
                    D(
                        :name => "Level_1",
                        :initial_size_range => [6000, 7300],
                        :proc_payload_groups => [
                            D(:size_ratio => "1/3", :proc_ratio => "1/8"),
                            D(:size_ratio => "2/3", :proc_ratio => "7/8"),
                        ],
                    ),
                ],
            ),
        ],
    )
    return config
end

function generate_config(filename::AbstractString = default_config_filename())
    if MPI.Comm_rank(MPI.COMM_WORLD) == 0
        YAML.write_file(filename, default_config())
        println("Generated config file: ", filename)
    end
    nothing
end

generate_config(::Nothing) = generate_config()
