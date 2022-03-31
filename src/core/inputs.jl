import ArgParse, YAML, MPI
import ArgParse: @project_version, @add_arg_table!, parse_args, ArgParseSettings
import OrderedCollections: LittleDict

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
    return "default.yaml"
end

function read_config(filename::AbstractString = default_config_filename())
    return YAML.load_file(filename, dicttype = LittleDict{Symbol,Any})
end

read_config(::Nothing) = read_config()

function default_config()
    D = LittleDict{Symbol,Any}
    config = [
        D(
            :dataset => "output",
            :name => "data 1",
            :nsteps => 10,
            :basename => "data_one",
            :compute_seconds => 0.001,
            :transport => "HDF5",
            :data_streams => [
                D(
                    :name => "Level0",
                    :evolution => "none",
                    :nprocs_ratio => 0.5,
                    :proc_payloads => [
                        D(:size_range => [5, 10], :ratio => 0.06),
                        D(:size_range => [10, 20], :ratio => 0.94),
                    ],
                ),
                D(
                    :name => "Level1",
                    :proc_payloads => [
                        D(:size_range => [5, 10], :ratio => 1//4),
                        D(:size_range => [10, 20], :ratio => 3//4),
                    ],
                ),
            ],
        ),
        D(
            :dataset => "output",
            :name => "data 2",
            :nsteps => 10,
            :basename => "data_two",
            :data_streams => [
                D(
                    :name => "Level0",
                    :proc_payloads => [
                        D(:size_range => [5, 10], :ratio => 0.06),
                        D(:size_range => [10, 20], :ratio => 0.94),
                    ],
                ),
                D(
                    :name => "Level1",
                    :proc_payloads => [
                        D(:size_range => [5, 10], :ratio => 1//8),
                        D(:size_range => [10, 20], :ratio => 7//8),
                    ],
                ),
            ],
        ),
    ]
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
