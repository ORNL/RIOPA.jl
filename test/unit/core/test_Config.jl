import ArgParse, RIOPA
import Test: @testset, @test, @test_throws

@testset "config" begin
    config = RIOPA.default_config()
    dscfg = config[:datasets][1]
    @test dscfg[:io_backend] == "HDF5"
    grpcfg = dscfg[:data_streams][1][:proc_payloads][2]
    @test grpcfg[:size_range] == [2000, 2400]
    @test grpcfg[:ratio] == 0.5
    filename = "testcase-temp-config.yaml"
    RIOPA.generate_config(filename)
    @test ispath(filename)
    config2 = RIOPA.read_config(filename)
    @test config2 == config
    rm(filename)
end
