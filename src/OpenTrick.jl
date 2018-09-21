module OpenTrick

export opentrick, rawio, blockingtask, unsafe_clear

const tasks_pending=Dict{Condition, Task}()

mutable struct IOWrapper{T <: IO}
    io::T
    cond::Condition
    function IOWrapper(io::T, c) where T
        obj = new{T}(io, c)
        finalizer(obj) do obj
            notify(obj.cond)
        end
    end
end

rawio(w::IOWrapper) = w.io
blockingtask(w::IOWrapper) = tasks_pending[w.cond]

function Base.close(w::IOWrapper)
    try
        close(rawio(w))
    catch e
        rethrow(e)
    finally
        finalize(w)
        yield()
    end
end

for fname in (:read, :read!, :readavailable, :readline, :write, :isopen, :eof)
    eval(quote
        Base.$fname(w::IOWrapper, args...; kwargs...) = $fname(rawio(w), args...; kwargs...)
    end)
end

"""
call blockreturn in other tasks like in @async block
"""
function notifyreturn(c, x)
    nof = IOWrapper(x, c)
    @debug "notifing caller..." nof
    notify(c, nof, all=false) # caller ought to be waiting for it
    nof = nothing # no longer keep reference to
    wait(c)
    @debug "notifyreturn finished"
end

"""
f must accept cond::Condition as its first argument
"""
function blockreturn(f::Function, args...; kwargs...)
    cond = Condition()
    task = @async begin
        try
            @debug "push!" cond current_task() tasks_pending
            push!(tasks_pending, cond => current_task() )
            @debug "calling ..." f args kwargs
            f(cond, args...; kwargs...)
            @debug "call returned" f
        catch e
            @debug "Caught Exception" e
            notify(cond, e, error=true)
        end
        @debug "delete!" current_task() tasks_pending
        delete!(tasks_pending, cond)
        @debug "deleted" tasks_pending

    end
    @debug "waiting" cond task
    return wait(cond)
end

function opentrick(open::Function, args...; kwargs...)
    blockreturn() do cond
        open(args ...; kwargs...) do stream
            notifyreturn(cond, stream)
        end
    end
end

function unsafe_clear()
    for (cond, task) in tasks_pending
        notify(cond, InterruptException(), error=true)
        yield()
    end
end
end # module
