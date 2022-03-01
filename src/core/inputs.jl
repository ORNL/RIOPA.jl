
mutable struct Inputs
    hello::String

    Inputs() = new("")
end


function parse_inputs(args)::Inputs

    inputs = Inputs()

    if size(args)[1] == 1

        arg1::String = args[1]

        if arg1 == "hello" || arg1 == "hello-adios2"
            inputs.hello = arg1
        else
            message = string("RIOPA: input argument ", arg1, " is not valid")
            throw(ArgumentError(message))
        end
    else
        message = string("RIOPA: input arguments are not valid")
        throw(ArgumentError(message))
    end

    return inputs
end
