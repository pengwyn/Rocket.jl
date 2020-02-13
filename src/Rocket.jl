module Rocket

include("utils.jl")

include("teardown.jl")
include("teardown/void.jl")
include("teardown/chain.jl")

include("actor.jl")
include("actor/function.jl")
include("actor/lambda.jl")
include("actor/logger.jl")
include("actor/void.jl")
include("actor/async.jl")
include("actor/sync.jl")
include("actor/keep.jl")

include("subscribable.jl")
include("operator.jl")
include("subject.jl")

include("subjects/base_types/asynchronous.jl")
include("subjects/base_types/synchronous.jl")
include("subjects/default.jl")

include("subjects/types/behavior.jl")
include("subjects/types/replay.jl")
include("subjects/types/network.jl")
include("subjects/types/pending.jl")

include("observable/single.jl")
include("observable/array.jl")
include("observable/error.jl")
include("observable/never.jl")
include("observable/completed.jl")
include("observable/proxy.jl")
include("observable/timer.jl")
include("observable/interval.jl")
include("observable/function.jl")
include("observable/file.jl")
include("observable/network.jl")
include("observable/combined.jl")
include("observable/collected.jl")
include("observable/lazy.jl")
include("observable/connectable.jl")

include("operators/map.jl")
include("operators/reduce.jl")
include("operators/scan.jl")
include("operators/filter.jl")
include("operators/some.jl")
include("operators/count.jl")
include("operators/enumerate.jl")
include("operators/take.jl")
include("operators/first.jl")
include("operators/last.jl")
include("operators/tap.jl")
include("operators/sum.jl")
include("operators/max.jl")
include("operators/min.jl")
include("operators/delay.jl")
include("operators/uppercase.jl")
include("operators/lowercase.jl")
include("operators/to_array.jl")
include("operators/tuple_with.jl")
include("operators/replay.jl")
include("operators/switchMap.jl")
include("operators/multicast.jl")
include("operators/ref_count.jl")
include("operators/publish.jl")
include("operators/share.jl")
include("operators/catch_error.jl")
include("operators/rerun.jl")
include("operators/safe.jl")
include("operators/noop.jl")

include("extensions/observable/single.jl")

end # module
