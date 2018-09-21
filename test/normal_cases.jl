using Test
using OpenTrick
@testset "open read succeed" begin
    io = opentrick(open, "sometext.txt", "r")
    @test "hello world!" == String(readline(io))
    @test !eof(io)
    @test length(OpenTrick.tasks_pending) == 1
    @debug "call close"
    close(io)
    @test !isopen(io)
    @test length(OpenTrick.tasks_pending) == 0
end

@testset "open write succeed" begin
    filename = tempname()
    outstring = "hello world!"
    out = opentrick(open, filename, "w")
    @test write(out, outstring) == length(outstring)
    @test length(OpenTrick.tasks_pending) == 1
    @debug "call finalize"
    close(out)
    @test !isopen(out)
    @test length(OpenTrick.tasks_pending) == 0
    infile = opentrick(open, filename, "r")
    @test String(read(infile)) == outstring
    @test eof(infile)
    close(infile)
    @test !isopen(rawio(infile))
    @test length(OpenTrick.tasks_pending) == 0
end

@testset "unsafe_clear" begin
    w1 = opentrick(open, "sometext.txt", "r")
    w2 = opentrick(open, "sometext.txt", "r")
    @test length(OpenTrick.tasks_pending) == 2
    unsafe_clear();
    @test length(OpenTrick.tasks_pending) == 0
    @test !isopen(w1)
    @test !isopen(w2)
end