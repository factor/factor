! (c)2009 Joe Groff bsd license
USING: accessors timers alien.c-types calendar classes.struct
continuations destructors fry kernel math math.order memory
namespaces sequences specialized-vectors system
tools.memory ui ui.gadgets.worlds vm vocabs.loader arrays
benchmark.struct ;
IN: game.loop

TUPLE: game-loop
    { tick-interval-nanos integer read-only }
    tick-delegate
    draw-delegate
    { last-tick integer }
    { running? boolean }
    { tick# integer }
    { frame# integer }
    timer
    benchmark-data ;

STRUCT: game-loop-benchmark
    { benchmark-data-pair benchmark-data-pair }
    { tick# ulonglong }
    { frame# ulonglong } ;

SPECIALIZED-VECTOR: game-loop-benchmark

: <game-loop-benchmark> ( benchmark-data-pair tick frame -- obj )
    \ game-loop-benchmark <struct>
        swap >>frame#
        swap >>tick#
        swap >>benchmark-data-pair ; inline

GENERIC: tick* ( delegate -- )
GENERIC: draw* ( tick-slice delegate -- )

SYMBOL: game-loop

: since-last-tick ( loop -- nanos )
    last-tick>> nano-count swap - ;

: tick-slice ( loop -- slice )
    [ since-last-tick ] [ tick-interval-nanos>> ] bi /f 1.0 min ;

CONSTANT: MAX-FRAMES-TO-SKIP 5

DEFER: stop-loop

TUPLE: game-loop-error game-loop error ;

: ?ui-error ( error -- )
    ui-running? [ ui-error ] [ rethrow ] if ;

: game-loop-error ( game-loop error -- )
    [ drop stop-loop ] [ \ game-loop-error boa ?ui-error ] 2bi ;

: fps ( fps -- nanos )
    1,000,000,000 swap /i ; inline

<PRIVATE

: record-benchmarking ( benchark-data-pair loop -- )
    [ tick#>> ]
    [ frame#>> <game-loop-benchmark> ]
    [ benchmark-data>> ] tri push ;

: redraw ( loop -- )
    [ 1 + ] change-frame#
    [
        [ tick-slice ] [ draw-delegate>> ] bi [ draw* ] with-benchmarking
    ] keep record-benchmarking ;

: tick ( loop -- )
    [
        [ tick-delegate>> tick* ] with-benchmarking
    ] keep record-benchmarking ;

: increment-tick ( loop -- )
    [ 1 + ] change-tick#
    dup tick-interval-nanos>> '[ _ + ] change-last-tick
    drop ;

: ?tick ( loop count -- )
    [ nano-count >>last-tick drop ] [
        over [ since-last-tick ] [ tick-interval-nanos>> ] bi >=
        [ [ drop increment-tick ] [ drop tick ] [ 1 - ?tick ] 2tri ]
        [ 2drop ] if
    ] if-zero ;

PRIVATE>

! : benchmark-ticks-per-second ( loop -- n )
    ! [ tick#>> ] [ benchmark-tick#>> - ] [ benchmark-nanos ] tri /f ;

! : benchmark-frames-per-second ( loop -- n )
    ! [ frame#>> ] [ benchmark-frame#>> - ] [ benchmark-nanos ] tri /f ;

: (game-tick) ( loop -- )
    dup running?>>
    [ [ MAX-FRAMES-TO-SKIP ?tick ] [ redraw ] bi ]
    [ drop ] if ;
    
: game-tick ( loop -- )
    dup game-loop [
        [ (game-tick) ] [ game-loop-error ] recover
    ] with-variable ;

: start-loop ( loop -- )
    nano-count >>last-tick
    t >>running?
    [
        [ '[ _ game-tick ] f ]
        [ tick-interval-nanos>> nanoseconds ] bi
        <timer>
    ] keep [ timer<< ] [ drop start-timer ] 2bi ;

: stop-loop ( loop -- )
    f >>running?
    timer>> stop-timer ;

: <game-loop*> ( tick-interval-nanos tick-delegate draw-delegate -- loop )
    nano-count f 0 0 f
    game-loop-benchmark-vector{ } clone
    game-loop boa ;

: <game-loop> ( tick-interval-nanos delegate -- loop )
    dup <game-loop*> ; inline

M: game-loop dispose
    stop-loop ;

{ "game.loop" "prettyprint" } "game.loop.prettyprint" require-when

