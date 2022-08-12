import RIOPA
import RIOPA: Ctrl, DataGen
import Test: @testset, @test, @test_throws

struct TestDataGenTag <: RIOPA.DataGen.DataGenTag end

@testset "DataGen" begin
    @test DataGen.get_tag(nothing) == DataGen.DefaultDataGenTag()
    @test_throws KeyError DataGen.get_tag("test")
    DataGen.add("test", TestDataGenTag())
    @test DataGen.get_tag("test") == TestDataGenTag()

    config = RIOPA.default_config()
    ds = Ctrl.configure_dataset(config[:datasets][1])
    str_cfg = ds.cfg.streams[1]
    @test RIOPA.get_payload_group_id_and_size(0, 4, str_cfg) == (1, 2)
    @test RIOPA.get_payload_group_id_and_size(1, 4, str_cfg) == (1, 2)
    @test RIOPA.get_payload_group_id_and_size(2, 4, str_cfg) == (2, 2)
    @test RIOPA.get_payload_group_id_and_size(3, 4, str_cfg) == (2, 2)

    @test RIOPA.get_payload_group_id_and_size(0, 4, ds.cfg.streams[2]) == (1, 1)
    @test RIOPA.get_payload_group_id_and_size(1, 4, ds.cfg.streams[2]) == (2, 3)
    @test RIOPA.get_payload_group_id_and_size(2, 4, ds.cfg.streams[2]) == (2, 3)
    @test RIOPA.get_payload_group_id_and_size(3, 4, ds.cfg.streams[2]) == (2, 3)

    @test RIOPA.get_payload_group_id_and_size(0, 5, ds.cfg.streams[1]) == (1, 2)
    @test RIOPA.get_payload_group_id_and_size(1, 5, ds.cfg.streams[1]) == (1, 2)
    @test RIOPA.get_payload_group_id_and_size(2, 5, ds.cfg.streams[1]) == (2, 3)
    @test RIOPA.get_payload_group_id_and_size(3, 5, ds.cfg.streams[1]) == (2, 3)
    @test RIOPA.get_payload_group_id_and_size(4, 5, ds.cfg.streams[1]) == (2, 3)

    @test RIOPA.get_payload_group_id_and_size(0, 1, str_cfg) == (2, 1)

    DataGen.generate!(DataGen.DefaultDataGenTag(), ds)
    @test 2000 <= length(ds.streams[1].data.vec) <= 2400
    @test 4000 <= length(ds.streams[2].data.vec) <= 4800
    ds.curr_step += 1
    DataGen.generate!(DataGen.DefaultDataGenTag(), ds)
    @test 4000 <= length(ds.streams[1].data.vec) <= 4800
    @test 6000 <= length(ds.streams[2].data.vec) <= 7200

    config[:datasets][1][:data_streams][1][:proc_payload_groups][1][:proc_ratio] =
        1.0
    @test_throws RIOPA.ProcessGroupRatioError Ctrl.configure_dataset(
        config[:datasets][1],
    )
end
