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
        help = "Run in hello mode (minimal functionality test)"
        action = :command
        "generate-config"
        help = """Create default config file
        (as "config.yaml" unless --config option is used)"""
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

function default_config()
    D = LittleDict{Symbol,Any}
    config = D(
        :io => D(
            :transport => "HDF5",
            :levels => [
                D(:level => 1, :size => [1.0e2, 3.0e2]),
                D(:level => 2, :size => [1.0e4, 3.0e4]),
                D(:level => 3, :size => [1.0e6, 3.0e6]),
            ],
        ),
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
