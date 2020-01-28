module RxKeepActorTest

using Test
using Rx

@testset "KeepActor" begin

    @testset begin
        source = from([ 1, 2, 3 ])
        actor  = KeepActor{Int}()

        subscribe!(source, actor)

        @test actor.values == [ 1, 2, 3 ]
    end

    @testset begin
        source = throwError("Error", Int)
        actor  = KeepActor{Int}()

        @test_throws ErrorException subscribe!(source, actor)
        @test actor.values == []
    end

    @testset begin
        @test keep(Int) isa KeepActor{Int}
    end
end

end