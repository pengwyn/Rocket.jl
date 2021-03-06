export skip_error

import Base: show

"""
    skip_error()

Creates a `skip_error` operator, which filters out `error` event by the source Observable by emitting only
`next` and `complete` messages.

# Producing

Stream of type `<: Subscribable{L}` where `L` refers to type of source stream

# Examples
```jldoctest
using Rocket

source = faulted("error")
subscribe!(source |> skip_error(), logger())
;

# output

```

See also: [`AbstractOperator`](@ref), [`InferableOperator`](@ref), [`ProxyObservable`](@ref), [`skip_error`](@ref), [`skip_complete`](@ref), [`logger`](@ref)
"""
skip_error() = SkipErrorOperator()

struct SkipErrorOperator <: InferableOperator end

function on_call!(::Type{L}, ::Type{L}, operator::SkipErrorOperator, source) where L
    return proxy(L, source, SkipErrorProxy())
end

operator_right(operator::SkipErrorOperator, ::Type{L}) where L = L

struct SkipErrorProxy <: ActorProxy end

actor_proxy!(::Type{L}, proxy::SkipErrorProxy, actor::A) where { L, A } = SkipErrorActor{L, A}(actor)

struct SkipErrorActor{L, A} <: Actor{L}
    actor :: A
end

on_next!(actor::SkipErrorActor{L}, data::L) where L = next!(actor.actor, data)
on_error!(actor::SkipErrorActor, err)               = begin end
on_complete!(actor::SkipErrorActor)                 = complete!(actor.actor)

Base.show(io::IO, ::SkipErrorOperator)         = print(io, "SkipErrorOperator()")
Base.show(io::IO, ::SkipErrorProxy)            = print(io, "SkipErrorProxy()")
Base.show(io::IO, ::SkipErrorActor{L}) where L = print(io, "SkipErrorActor($L)")
