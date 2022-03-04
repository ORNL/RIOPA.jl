
# mutable struct Inputs
#     hello::String

#     Inputs() = new("")
# end

using ArgParse

function parse_inputs(args)

    s = ArgParseSettings(description = "Hey!")
    @add_arg_table! s begin
        "--config", "-c"
            help = "Specify (YAML) config file to generate I/O: config.yaml"
            arg_type = String
        "--generate-config", "-g"
            help = "Create default config file"
            action = :store_true
        # "--opt2", "-o"
        #     help = "another option with an argument"
        #     arg_type = Int
        #     default = 0
        "--hello", "-w"
            help = "Run in hello mode (minimal test)"
            action = :store_true
        # "arg1"
        #     help = "a positional argument"
        #     required = true
    end

    return parse_args(args, s)

    # inputs = Inputs()

    # if size(args)[1] == 1

    #     arg1::String = args[1]

    #     if arg1 == "hello" || arg1 == "hello-adios2"
    #         inputs.hello = arg1
    #     else
    #         message = string("RIOPA: input argument ", arg1, " is not valid")
    #         throw(ArgumentError(message))
    #     end
    # else
    #     message = string("RIOPA: input arguments are not valid")
    #     throw(ArgumentError(message))
    # end

    # return inputs
end
