using MPI, MLStyle

import RIOPA


function main(args)::Int32

    inputs = RIOPA.parse_inputs(args)

    configFile = inputs["config"]

    command = inputs["%COMMAND%"]
    @match command begin
        "hello" => println("Hello mode; config file: ", configFile)
        "generate-config" => RIOPA.generate_config(configFile)
        nothing => println("Normal mode; config file: ", configFile)
    end

    return 0

end
