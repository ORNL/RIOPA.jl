
using ArgParse

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
