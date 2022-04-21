import ArgParse, YAML, MPI, OrderedCollections
import ArgParse: @project_version, @add_arg_table!, parse_args, ArgParseSettings

function parse_inputs(args; error_handler = ArgParse.default_handler)
    s = ArgParseSettings(
        description = "Reproducible Input Ouput (I/O) Pattern Application (RIOPA)",
        add_version = true,
        version = @project_version,
        commands_are_required = false,
        exc_handler = error_handler,
    )
    @add_arg_table! s begin
        "hello"
        help = """Run in "hello" mode (minimal functionality)"""
        action = :command
        "generate-config", "gencfg"
        help = """Create default configuration file
        (as "$(default_config_filename())" unless --config option is used)"""
        action = :command
        "--config", "-c"
        help = "Specify name of (YAML) config file to generate I/O"
        arg_type = String
    end

    inputs = parse_args(args, s)

    return inputs
end

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
                        :evolution => "none",
                        :nprocs_ratio => 0.5,
                        :proc_payloads => [
                            D(:size_range => [1000, 1200], :ratio => 0.1),
                            D(:size_range => [2000, 2400], :ratio => 0.9),
                        ],
                    ),
                    D(
                        :name => "Level_1",
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
        ]
    )
    return config
end

function generate_config(filename::AbstractString = default_config_filename())
    if getmpiworldrank() == 0
        YAML.write_file(filename, default_config())
        println("Generated config file: ", filename)
    end
    nothing
end

generate_config(::Nothing) = generate_config()
