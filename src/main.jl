import MPI, RIOPA
import MLStyle: @match

function main(args)::Int32
    inputs = RIOPA.parse_inputs(args)

    config_filename = inputs["config"]

    command = inputs["%COMMAND%"]
    @match command begin
        "hello" => RIOPA.hello(config_filename)
        "generate-config" => RIOPA.generate_config(config_filename)
        nothing => println("Normal mode; config file: ", config_filename)
    end

    return 0
end
