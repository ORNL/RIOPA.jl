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
                :compute_seconds => 1.0,
                :data_streams => [
                    D(
                        :name => "Level_0",
                        :evolution => D(
                            :function => "GrowthFactor",
                            :params => [2.0],
                        ),
                        :nprocs_ratio => 0.5,
                        :proc_payloads => [
                            D(:size_range => [1000, 1200], :ratio => 0.5),
                            D(:size_range => [2000, 2400], :ratio => 0.5),
                        ],
                    ),
                    D(
                        :name => "Level_1",
                        :evolution => D(
                            :function => "Polynomial",
                            :params => [0.0, 1.0],
                        ),
                        :proc_payloads => [
                            D(:size_range => [2000, 2500], :ratio => "1/4"),
                            D(:size_range => [4000, 4800], :ratio => "3/4"),
                        ],
                    ),
                ],
            ),
            D(
                :type => "output",
                :name => "data 2",
                :io_backend => "HDF5",
                :basename => "data_two",
                :nsteps => 3,
                :compute_seconds => 3.0,
                :data_streams => [
                    D(
                        :name => "Level_0",
                        :proc_payloads => [
                            D(:size_range => [1000, 1200], :ratio => 0.1),
                            D(:size_range => [2000, 2400], :ratio => 0.9),
                        ],
                    ),
                    D(
                        :name => "Level_1",
                        :proc_payloads => [
                            D(:size_range => [2000, 2500], :ratio => "1/8"),
                            D(:size_range => [4000, 4800], :ratio => "7/8"),
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
