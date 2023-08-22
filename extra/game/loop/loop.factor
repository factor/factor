! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar continuations destructors kernel
math math.order system timers ui ui.gadgets.worlds vocabs.loader ;
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

GENERIC: tick* ( delegate -- )
GENERIC: draw* ( tick-slice delegate -- )

DEFER: stop-loop

TUPLE: game-loop-error-state error game-loop ;

: ?ui-error ( error -- )
    ui-running? [ ui-error ] [ rethrow ] if ;

: game-loop-error ( error game-loop -- )
    [ nip stop-loop ] [ \ game-loop-error-state boa ?ui-error ] 2bi ;

: fps ( fps -- nanos )
    [ 1,000,000,000 ] dip /i ; inline

<PRIVATE

: last-tick-percent-offset ( loop -- float )
    [ draw-timer>> next-nanos>> nano-count - ]
    [ tick-interval-nanos>> ] bi /f 1.0 swap -
    0.0 1.0 clamp ;

GENERIC#: record-benchmarking 1 ( loop quot -- )

M: object record-benchmarking
    call( loop -- ) ;

: redraw ( loop -- )
    [ 1 + ] change-frame#
    [
        [ last-tick-percent-offset ] [ draw-delegate>> ] bi
        draw*
    ] record-benchmarking ;

: tick ( loop -- )
    [ tick-delegate>> tick* ] record-benchmarking ;

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
    f 0 0 f f f game-loop boa ;

: <game-loop> ( tick-interval-nanos delegate -- loop )
    dup <game-loop*> ; inline

M: game-loop dispose
    stop-loop ;

{ "game.loop" "prettyprint" } "game.loop.prettyprint" require-when
{ "game.loop" "tools.memory" } "game.loop.benchmark" require-when
