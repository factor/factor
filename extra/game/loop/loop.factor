! (c)2009 Joe Groff bsd license
USING: accessors timers alien.c-types calendar classes.struct
continuations destructors fry kernel math math.order memory
namespaces sequences specialized-vectors system
ui ui.gadgets.worlds vm vocabs.loader arrays
tools.time.struct locals ;
IN: game.loop

TUPLE: game-loop
    { tick-interval-nanos integer read-only }
    tick-delegate
    draw-delegate
    { running? boolean }
    { tick# integer }
    { frame# integer }
    tick-timer
    draw-timer
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

DEFER: stop-loop

TUPLE: game-loop-error game-loop error ;

: ?ui-error ( error -- )
    ui-running? [ ui-error ] [ rethrow ] if ;

: game-loop-error ( game-loop error -- )
    [ drop stop-loop ] [ \ game-loop-error boa ?ui-error ] 2bi ;

: fps ( fps -- nanos )
    [ 1,000,000,000 ] dip /i ; inline

<PRIVATE

: record-benchmarking ( benchark-data-pair loop -- )
    [ tick#>> ]
    [ frame#>> <game-loop-benchmark> ]
    [ benchmark-data>> ] tri push ;

: last-tick-percent-offset ( loop -- float )
    [ draw-timer>> iteration-start-nanos>> nano-count swap - ]
    [ tick-interval-nanos>> ] bi /f 1.0 min ;

: redraw ( loop -- )
    [ 1 + ] change-frame#
    [
        [ last-tick-percent-offset ] [ draw-delegate>> ] bi
        [ draw* ] with-benchmarking
    ] keep record-benchmarking ;

: tick ( loop -- )
    [
        [ tick-delegate>> tick* ] with-benchmarking
    ] keep record-benchmarking ;

: increment-tick ( loop -- )
    [ 1 + ] change-tick#
    drop ;

PRIVATE>

:: when-running ( loop quot -- )
    [
        loop
        dup running?>> quot [ drop ] if
    ] [
        loop game-loop-error
    ] recover ; inline

: tick-iteration ( loop -- )
    [ [ tick ] [ increment-tick ] bi ] when-running ;

: frame-iteration ( loop -- )
    [ redraw ] when-running ;

: start-loop ( loop -- )
    t >>running?

    dup
    [ '[ _ tick-iteration ] f ]
    [ tick-interval-nanos>> nanoseconds ] bi <timer> >>tick-timer

    dup '[ _ frame-iteration ] f 1 milliseconds <timer> >>draw-timer

    [ tick-timer>> ] [ draw-timer>> ] bi [ start-timer ] bi@ ;

: stop-loop ( loop -- )
    f >>running?
    [ tick-timer>> ] [ draw-timer>> ] bi [ stop-timer ] bi@ ;

: <game-loop*> ( tick-interval-nanos tick-delegate draw-delegate -- loop )
    f 0 0 f f
    game-loop-benchmark-vector{ } clone
    game-loop boa ;

: <game-loop> ( tick-interval-nanos delegate -- loop )
    dup <game-loop*> ; inline

M: game-loop dispose
    stop-loop ;

{ "game.loop" "prettyprint" } "game.loop.prettyprint" require-when
