import RIOPA
import Test: @testset, @test, @test_throws

mutable struct TestTag <: RIOPA.Ctrl.TagBase
    datacount::Int
    times::Vector{Float64}
end

TestTag() = TestTag(0, [])

function RIOPA.Ctrl.generate_data!(tag::TestTag, ds::RIOPA.Ctrl.DataSet)
    # ds.data = rand(Float64, 10^6)
    tag.datacount += 1
end

function RIOPA.Ctrl.perform_io_step(tag::TestTag, ds::RIOPA.Ctrl.DataSet)
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

@testset "ctrl" begin
    tag1 = TestTag()
    tag3 = TestTag()
    ds_configs = [
        RIOPA.Ctrl.DataSetConfig("test1", tag1, tag1, 6, 1.0),
        RIOPA.Ctrl.DataSetConfig("test2", tag3, tag3, 2, 3.0),
    ]
    RIOPA.Ctrl.run_internal(map(cfg -> RIOPA.Ctrl.DataSet(cfg), ds_configs))

    @test tag1.datacount == 6
    for t in tag1.times
        @test abs(t - 1.0) < 0.3
    end

    @test tag3.datacount == 2
    for t in tag3.times
        @test abs(t - 3.0) < 0.3
    end
end
