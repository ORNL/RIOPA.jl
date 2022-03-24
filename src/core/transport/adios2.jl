

import ADIOS2

function hello_adios2(basename::AbstractString, data::AbstractString)
    adios = ADIOS2.adios_init_serial()
    io = ADIOS2.declare_io(adios, "IO")
    engine = open(io, basename*".bp", ADIOS2.mode_write)
    v = ADIOS2.define_variable(io, "hello", data)
    ADIOS2.put!(engine, v, data)
    ADIOS2.perform_puts!(engine)
    close(engine)
end
