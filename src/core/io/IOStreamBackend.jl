import MPI

import RIOPA: IO

struct IOStreamTag <: IO.IOTag end

function IO.write_data_object(
    ::IOStreamTag,
    pathname::AbstractString,
    data::DataObject,
)
    worldrank = MPI.Comm_rank(MPI.COMM_WORLD)
    filename = "D_" * lpad(worldrank, 5, '0') * ".dat"
    write(pathname * "/" * filename, "data", data.vec)
end

IO.add("IOStream", IOStreamTag())
