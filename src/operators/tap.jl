export tap
export TapOperator, on_call!, operator_right
export TapProxy, actor_proxy!
export TapActor, on_next!, on_error!, on_complete!
export @CreateTapOperator

"""
    tap(tapFn::Function)

Creates a tap operator, which performs a side effect
for every emission on the source Observable, but return an Observable that is identical to the source.

# Arguments
- `tapFn::Function`: side-effect tap function with `(data) -> Nothing` signature

# Producing

Stream of type `<: Subscribable{L}` where `L` refers to type of source stream

# Examples
```jldoctest
using Rx

source = from([ 1, 2, 3 ])
subscribe!(source |> tap((d) -> println("In tap: \$d")), LoggerActor{Int}())
;

# output

In tap: 1
[LogActor] Data: 1
In tap: 2
[LogActor] Data: 2
In tap: 3
[LogActor] Data: 3
[LogActor] Completed

```

See also: [`AbstractOperator`](@ref), [`InferableOperator`](@ref), [`ProxyObservable`](@ref)
"""
tap(tapFn::Function) = TapOperator(tapFn)

struct TapOperator <: InferableOperator
    tapFn :: Function
end

operator_right(operator::TapOperator, ::Type{L}) where L = L

function on_call!(::Type{L}, ::Type{L}, operator::TapOperator, source) where L
    return ProxyObservable{L}(source, TapProxy{L}(operator.tapFn))
end

struct TapProxy{L} <: ActorProxy
    tapFn :: Function
end

actor_proxy!(proxy::TapProxy{L}, actor::A) where { A <: AbstractActor{L} } where L = TapActor{L, A}(proxy.tapFn, actor)

struct TapActor{L, A <: AbstractActor{L} } <: Actor{L}
    tapFn :: Function
    actor :: A
end

function on_next!(t::TapActor{L, A}, data::L) where { A <: AbstractActor{L} } where L
    Base.invokelatest(t.tapFn, data)
    next!(t.actor, data)
end

on_error!(t::TapActor{L, A}, err) where { A <: AbstractActor{L} } where L = error!(t.actor, err)
on_complete!(t::TapActor{L, A})   where { A <: AbstractActor{L} } where L = complete!(t.actor)

"""
    @CreateTapOperator(name, tapFn)

Creates a custom tap operator, which can be used as `nameTapOperator()`.

# Arguments
- `name`: custom operator name
- `tapFn`: side-effect tap function

# Generates
- `nameTapOperator()` function

# Examples
```jldoctest
using Rx

@CreateTapOperator("Print", (d) -> println("In tap: \$d"))

source = from([ 1, 2, 3 ])
subscribe!(source |> PrintTapOperator(), LoggerActor{Int}())
;

# output

In tap: 1
[LogActor] Data: 1
In tap: 2
[LogActor] Data: 2
In tap: 3
[LogActor] Data: 3
[LogActor] Completed

```

"""
macro CreateTapOperator(name, tapFn)
    operatorName = Symbol(name, "TapOperator")
    proxyName    = Symbol(name, "TapProxy")
    actorName    = Symbol(name, "TapActor")

    operatorDefinition = quote
        struct $operatorName <: Rx.InferableOperator end

        function Rx.on_call!(::Type{L}, ::Type{L}, operator::($operatorName), source) where L
            return Rx.ProxyObservable{L}(source, ($proxyName){L}())
        end

        Rx.operator_right(operator::($operatorName), ::Type{L}) where L = L
    end

    proxyDefinition = quote
        struct $proxyName{L} <: Rx.ActorProxy end

        Rx.actor_proxy!(proxy::($proxyName){L}, actor::A) where { A <: Rx.AbstractActor{L} } where L = ($actorName){L, A}(actor)
    end

    actorDefinition = quote
        struct $actorName{L, A <: Rx.AbstractActor{L} } <: Rx.Actor{L}
            actor :: A
        end

        function Rx.on_next!(actor::($actorName){L, A}, data::L) where { A <: Rx.AbstractActor{L} } where L
            __inlined_lambda = $tapFn
            __inlined_lambda(data)
            Rx.next!(actor.actor, data)
        end

        Rx.on_error!(actor::($actorName){L, A}, err) where { A <: Rx.AbstractActor{L} } where L = Rx.next!(actor.actor, err)
        Rx.on_complete!(actor::($actorName){L, A})   where { A <: Rx.AbstractActor{L} } where L = Rx.complete!(actor.actor)
    end

    generated = quote
        $operatorDefinition
        $proxyDefinition
        $actorDefinition
    end

    return esc(generated)
end
