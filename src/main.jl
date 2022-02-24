
import MPI
import RIOPA


function main(args)::Int32

    MPI.Init()

    try

        inputs::RIOPA.Inputs = RIOPA.InputsParser(args)

    catch

    end

    MPI.Finalize()

    return 0

end

