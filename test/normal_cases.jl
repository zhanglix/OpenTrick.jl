using Test
using OpenTrick

@testset "open succeed" begin
    wrapper = opentrick(open, "sometext.txt", "r")
    @test "hello world!" == String(readline(wrapper.value))
    @test length(OpenTrick.tasks_pending) == 1
    @debug "call finalize"
    finalize(wrapper)
    wait(collect(keys(OpenTrick.tasks_pending))[1])
    @test !isopen(wrapper.value)
    @test length(OpenTrick.tasks_pending) == 0
end