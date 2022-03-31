

import ADIOS2

function hello_adios2(data::AbstractString)
    adios = ADIOS2.adios_init_mpi(MPI.COMM_WORLD)
    io = ADIOS2.declare_io(adios, "IO")
    open(io, "hello.bp", ADIOS2.mode_write) do engine
        v = ADIOS2.define_variable(io, "hello", data)
        ADIOS2.put!(engine, v, data)
    end
end
