import RIOPA
import Test: @testset, @test, @test_throws

@testset "Ctrl-cfg" begin
    config = RIOPA.default_config()
    dscfg_raw = config[:datasets][1]
    streamcfg = RIOPA.Ctrl.configure_stream(dscfg_raw[:data_streams][1])

    @test streamcfg.name == "Level_0"
    @test streamcfg.initial_size_range == (3000, 3600)
    @test streamcfg.payload_groups[1].size_ratio == 1.0/3.0
    @test streamcfg.payload_groups[1].proc_ratio == 0.5
    @test streamcfg.payload_groups[2].size_ratio == 2.0/3.0
    @test streamcfg.payload_groups[2].proc_ratio == 0.5

    ds = RIOPA.Ctrl.configure_dataset(dscfg_raw)
    @test ds.cfg.name == "data 1"
    @test ds.cfg.basename == "data_one"
    @test ds.cfg.datagen_backend_tag == RIOPA.DataGen.DefaultDataGenTag()
    @test ds.cfg.io_backend_tag == RIOPA.HDF5IOTag()
    @test ds.cfg.nsteps == 10
    @test ds.cfg.compute_seconds == 1.0
    @test length(ds.cfg.streams) == 2
    streamcfg = ds.cfg.streams[1]
    @test streamcfg.name == "Level_0"
    @test streamcfg.initial_size_range == (3000, 3600)
    @test streamcfg.payload_groups[1].size_ratio == 1.0/3.0
    @test streamcfg.payload_groups[1].proc_ratio == 0.5
    @test streamcfg.payload_groups[2].size_ratio == 2.0/3.0
    @test streamcfg.payload_groups[2].proc_ratio == 0.5
    streamcfg = ds.cfg.streams[2]
    @test streamcfg.name == "Level_1"
    @test streamcfg.initial_size_range == (6000, 7200)
    @test streamcfg.payload_groups[1].size_ratio == 1.0/3.0
    @test streamcfg.payload_groups[1].proc_ratio == 1 // 4
    @test streamcfg.payload_groups[2].size_ratio == 2.0/3.0
    @test streamcfg.payload_groups[2].proc_ratio == 3 // 4
end

mutable struct TestTag <: RIOPA.TagBase
    datacount::Int32
    times::Vector{Float64}
end

TestTag() = TestTag(0, [])

function RIOPA.DataGen.generate!(tag::TestTag, ds::RIOPA.Ctrl.DataSet)
    # ds.data = rand(Float64, 10^6)
    tag.datacount += 1
end

function RIOPA.IO.perform_step(tag::TestTag, ds::RIOPA.Ctrl.DataSet)
    # println(
    #     "time: ",
    #     time() - ds.timestamp,
    #     "s; ",
    #     ds.cfg.name,
    #     ": step ",
    #     ds.curr_step,
    # )
    push!(tag.times, time() - ds.timestamp)
end

@testset "Controller" begin
    # Run once to get rid of compiler time
    tag1 = TestTag()
    ds_configs =
        [RIOPA.Ctrl.DataSetConfig("test1", "test1", tag1, tag1, 1, 1, 0.25, [])]
    RIOPA.Ctrl.Controller(map(RIOPA.Ctrl.DataSet, ds_configs))()

    tag1 = TestTag()
    tag3 = TestTag()
    ds_configs = [
        RIOPA.Ctrl.DataSetConfig("test1", "test1", tag1, tag1, 6, 1, 1.0, []),
        RIOPA.Ctrl.DataSetConfig("test2", "test2", tag3, tag3, 2, 1, 3.0, []),
    ]
    RIOPA.Ctrl.Controller(map(RIOPA.Ctrl.DataSet, ds_configs))()

    @test tag1.datacount == 6
    for t in tag1.times
        @test abs(t - 1.0) < 0.1
    end

    @test tag3.datacount == 2
    for t in tag3.times
        @test abs(t - 3.0) < 0.1
    end
end
