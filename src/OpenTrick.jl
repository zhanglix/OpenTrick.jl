module OpenTrick

export opentrick, unsafe_clear

const tasks_pending=Dict{Task, Condition}()

mutable struct ValueWrapper{T}
    value::T
    cond::Condition
    function ValueWrapper(v::T, c) where T
        obj = new{T}(v, c)
        finalizer(obj) do obj
            notify(obj.cond)
        end
    end
end

"""
call blockreturn in other tasks like in @async block
"""
function notifyreturn(c, x)
    nof = ValueWrapper(x, c)
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
            @debug "push!" current_task() cond tasks_pending
            push!(tasks_pending, current_task() => cond)
            @debug "calling ..." f args kwargs
            f(cond, args...; kwargs...)
            @debug "call returned" f
        catch e
            @debug "Caught Exception" e
            notify(cond, e, error=true)
        end
        @debug "delete!" current_task() tasks_pending
        delete!(tasks_pending, current_task())
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
    for (task, cond) in tasks_pending
        notify(cond, InterruptException(), error=true)
        yield()
    end
end
end # module
