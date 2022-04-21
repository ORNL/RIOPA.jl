import RIOPA
import Test: @testset, @test, @test_throws

struct TestDataGenTag <: RIOPA.DataGen.DataGenTag end

@testset "DataGen" begin
    @test RIOPA.DataGen.get_tag(nothing) == RIOPA.DataGen.DefaultDataGenTag()
    @test_throws KeyError RIOPA.DataGen.get_tag("test")
    RIOPA.DataGen.add("test", TestDataGenTag())
    @test RIOPA.DataGen.get_tag("test") == TestDataGenTag()

    config = RIOPA.default_config()
    ds = RIOPA.Ctrl.configure_dataset(config[:datasets][1])
    str_cfg = ds.cfg.streams[1]
    @test RIOPA.DataGen.get_payload_group_id(0, 4, str_cfg) == 1
    @test RIOPA.DataGen.get_payload_group_id(1, 4, str_cfg) == 1
    @test RIOPA.DataGen.get_payload_group_id(2, 4, str_cfg) == 2
    @test RIOPA.DataGen.get_payload_group_id(3, 4, str_cfg) == 2

    @test RIOPA.DataGen.get_payload_group_id(0, 4, ds.cfg.streams[2]) == 1
    @test RIOPA.DataGen.get_payload_group_id(1, 4, ds.cfg.streams[2]) == 2
    @test RIOPA.DataGen.get_payload_group_id(2, 4, ds.cfg.streams[2]) == 2
    @test RIOPA.DataGen.get_payload_group_id(3, 4, ds.cfg.streams[2]) == 2

    @test RIOPA.DataGen.get_payload_group_id(0, 5, ds.cfg.streams[1]) == 1
    @test RIOPA.DataGen.get_payload_group_id(1, 5, ds.cfg.streams[1]) == 1
    @test RIOPA.DataGen.get_payload_group_id(2, 5, ds.cfg.streams[1]) == 2
    @test RIOPA.DataGen.get_payload_group_id(3, 5, ds.cfg.streams[1]) == 2
    @test RIOPA.DataGen.get_payload_group_id(4, 5, ds.cfg.streams[1]) == 2

    @test RIOPA.DataGen.get_payload_group_id(0, 1, str_cfg) == 2

    RIOPA.DataGen.generate!(RIOPA.DataGen.DefaultDataGenTag(), ds)
    sz = length(ds.streams[1].vec)
    @test 2000 <= sz <= 2400

    config[:datasets][1][:data_streams][1][:proc_payloads][1][:ratio] = 1.0
    @test_throws RIOPA.DataGen.ProcessPayloadRatioError RIOPA.Ctrl.configure_dataset(
        config[:datasets][1],
    )
end
