import ArgParse, RIOPA
import Test: @testset, @test, @test_throws

@testset "config" begin
    config = RIOPA.default_config()
    dscfg = config[:datasets][1]
    @test dscfg[:io_backend] == "HDF5"
    @test dscfg[:data_streams][1][:initial_size_range] == [3000, 3600]
    grpcfg = dscfg[:data_streams][1][:proc_payload_groups][2]
    @test RIOPA.get_ratio(grpcfg[:size_ratio]) == 2.0/3.0
    @test grpcfg[:proc_ratio] == 0.5
    filename = "testcase-temp-config.yaml"
    RIOPA.generate_config(filename)
    @test ispath(filename)
    config2 = RIOPA.read_config(filename)
    @test config2 == config
    rm(filename)
end
