import RIOPA
import Test: @testset, @test, @test_throws

struct TestIOTag <: RIOPA.IO.IOTag end

@testset "IO" begin
    @test RIOPA.IO.get_tag(nothing) == RIOPA.IO.DefaultIOTag()
    @test_throws KeyError RIOPA.IO.get_tag("test")
    RIOPA.IO.add("test", TestIOTag())
    @test RIOPA.IO.get_tag("test") == TestIOTag()
end

@testset "IO Backends" begin
    data = RIOPA.DataVector(rand(Float64, 10))
    @test RIOPA.IO.get_tag("HDF5") == RIOPA.HDF5IOTag()
    RIOPA.IO.write_data_object(RIOPA.HDF5IOTag(), pwd(), data)
    @test_exists_and_rm "D_00000.h5"

    @test RIOPA.IO.get_tag("IOStream") == RIOPA.IOStreamTag()
    RIOPA.IO.write_data_object(RIOPA.IOStreamTag(), pwd(), data)
    @test_exists_and_rm "D_00000.dat"
end
