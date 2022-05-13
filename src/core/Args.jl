import ArgParse
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
