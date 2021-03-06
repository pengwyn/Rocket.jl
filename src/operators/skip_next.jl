export skip_next

import Base: show

"""
    skip_next()

Creates a `skip_next` operator, which filters out all `next` messages by the source Observable by emitting only
`error` and `complete` messages.

# Producing

Stream of type `<: Subscribable{L}` where `L` refers to type of source stream

# Examples
```jldoctest
using Rocket

source = from([ 1, 2, 3 ])
subscribe!(source |> skip_next(), logger())
;

# output
[LogActor] Completed

```

See also: [`AbstractOperator`](@ref), [`InferableOperator`](@ref), [`ProxyObservable`](@ref), [`skip_error`](@ref), [`skip_complete`](@ref), [`logger`](@ref)
"""
skip_next() = SkipNextOperator()

struct SkipNextOperator <: InferableOperator end

function on_call!(::Type{L}, ::Type{L}, operator::SkipNextOperator, source) where L
    return proxy(L, source, SkipNextProxy())
end

operator_right(operator::SkipNextOperator, ::Type{L}) where L = L

struct SkipNextProxy <: ActorProxy end

actor_proxy!(::Type{L}, proxy::SkipNextProxy, actor::A) where { L, A } = SkipNextActor{L, A}(actor)

struct SkipNextActor{L, A} <: Actor{L}
    actor :: A
end

on_next!(actor::SkipNextActor{L}, data::L) where L = begin end
on_error!(actor::SkipNextActor, err)               = error!(actor.actor, err)
on_complete!(actor::SkipNextActor)                 = complete!(actor.actor)

Base.show(io::IO, ::SkipNextOperator)         = print(io, "SkipNextOperator()")
Base.show(io::IO, ::SkipNextProxy)            = print(io, "SkipNextProxy($L)")
Base.show(io::IO, ::SkipNextActor{L}) where L = print(io, "SkipNextActor($L)")
