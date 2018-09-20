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

@testset "unsafe_clear" begin
    w1 = opentrick(open, "sometext.txt", "r")
    w2 = opentrick(open, "sometext.txt", "r")
    @test length(OpenTrick.tasks_pending) == 2
    unsafe_clear();
    @test length(OpenTrick.tasks_pending) == 0
    @test !isopen(w1.value)
    @test !isopen(w2.value)
end