export LazyObservable, lazy, set!

import Base: show

# TODO: Untested and undocumented

mutable struct LazyObservableProps
    isready :: Bool

    LazyObservableProps() = new(false)
end

struct LazyObservable{D, S} <: Subscribable{D}
    pending :: S
    props   :: LazyObservableProps
end

isready(lazy::LazyObservable)   = lazy.props.isready
setready!(lazy::LazyObservable) = lazy.props.isready = true

function LazyObservable(::Type{T}, pending::S) where { T, S }
    return LazyObservable{T, S}(pending, LazyObservableProps())
end

set!(lazy::LazyObservable, observable::S) where S = on_lazy_set!(lazy, as_subscribable(S), observable)

on_lazy_set!(lazy::LazyObservable{D},  ::InvalidSubscribable,        observable) where D  = throw(InvalidSubscribableTraitUsageError(observable))
on_lazy_set!(lazy::LazyObservable{D1}, ::ValidSubscribableTrait{D2}, observable) where { D1, D2 <: D1 } = begin
    next!(lazy.pending, observable)
    complete!(lazy.pending)
    setready!(lazy)
    return nothing
end

function on_subscribe!(observable::LazyObservable{D}, actor) where D
    return subscribe!(observable.pending |> switch_map(D), actor)
end

lazy(::Type{T} = Any) where T = LazyObservable(T, PendingSubject(Any))

Base.show(io::IO, observable::LazyObservable{D}) where D = print(io, "LazyObservable($D)")
