
using ArgParse, OrderedCollections, YAML

function parse_inputs(args; error_handler = ArgParse.default_handler)

    s = ArgParseSettings(description = "Hey!", exc_handler = error_handler)
    @add_arg_table! s begin
        "--hello", "-m"
        help = "Run in hello mode (minimal functionality test)"
        action = :store_true
        "--config", "-c"
        help = "Specify (YAML) config file to generate I/O: config.yaml"
        arg_type = String
        "--generate-config", "-g"
        help = "Create default config file"
        action = :store_true
    end

    inputs = parse_args(args, s)

    return inputs
end

function read_config(filename::AbstractString)
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

function generate_config()
    YAML.write_file("config.yaml", default_config())
    nothing
end
