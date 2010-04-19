! (c)2009 Joe Groff bsd license
USING: accessors calendar continuations destructors kernel math
math.order namespaces system threads ui ui.gadgets.worlds
sequences ;
IN: game.loop

TUPLE: game-loop
    { tick-interval-micros integer read-only }
    tick-delegate
    draw-delegate
    { last-tick integer }
    thread 
    { running? boolean }
    { tick-number integer }
    { frame-number integer }
    { benchmark-time integer }
    { benchmark-tick-number integer }
    { benchmark-frame-number integer } ;

GENERIC: tick* ( delegate -- )
GENERIC: draw* ( tick-slice delegate -- )

SYMBOL: game-loop

: since-last-tick ( loop -- microseconds )
    last-tick>> system-micros swap - ;

: tick-slice ( loop -- slice )
    [ since-last-tick ] [ tick-interval-micros>> ] bi /f 1.0 min ;

CONSTANT: MAX-FRAMES-TO-SKIP 5

DEFER: stop-loop

TUPLE: game-loop-error game-loop error ;

: ?ui-error ( error -- )
    ui-running? [ ui-error ] [ rethrow ] if ;

: game-loop-error ( game-loop error -- )
    [ drop stop-loop ] [ \ game-loop-error boa ?ui-error ] 2bi ;

: fps ( fps -- micros )
    1,000,000 swap /i ; inline

<PRIVATE

: redraw ( loop -- )
    [ 1 + ] change-frame-number
    [ tick-slice ] [ draw-delegate>> ] bi draw* ;

: tick ( loop -- )
    tick-delegate>> tick* ;

: increment-tick ( loop -- )
    [ 1 + ] change-tick-number
    dup tick-interval-micros>> [ + ] curry change-last-tick
    drop ;

: ?tick ( loop count -- )
    [ system-micros >>last-tick drop ] [
        over [ since-last-tick ] [ tick-interval-micros>> ] bi >=
        [ [ drop increment-tick ] [ drop tick ] [ 1 - ?tick ] 2tri ]
        [ 2drop ] if
    ] if-zero ;

: (run-loop) ( loop -- )
    dup running?>>
    [ [ MAX-FRAMES-TO-SKIP ?tick ] [ redraw ] [ yield (run-loop) ] tri ]
    [ drop ] if ;

: run-loop ( loop -- )
    dup game-loop
    [ [ (run-loop) ] [ game-loop-error ] recover ]
    with-variable ;

: benchmark-micros ( loop -- micros )
    system-micros swap benchmark-time>> - ;

PRIVATE>

: reset-loop-benchmark ( loop -- )
    system-micros >>benchmark-time
    dup tick-number>> >>benchmark-tick-number
    dup frame-number>> >>benchmark-frame-number
    drop ;

: benchmark-ticks-per-second ( loop -- n )
    [ tick-number>> ] [ benchmark-tick-number>> - ] [ benchmark-micros ] tri /f ;
: benchmark-frames-per-second ( loop -- n )
    [ frame-number>> ] [ benchmark-frame-number>> - ] [ benchmark-micros ] tri /f ;

: start-loop ( loop -- )
    system-micros >>last-tick
    t >>running?
    [ reset-loop-benchmark ]
    [ [ run-loop ] curry "game loop" spawn ]
    [ (>>thread) ] tri ;

: stop-loop ( loop -- )
    f >>running?
    f >>thread
    drop ;

: <game-loop*> ( tick-interval-micros tick-delegate draw-delegate -- loop )
    system-micros f f 0 0 system-micros 0 0
    game-loop boa ;

: <game-loop> ( tick-interval-micros delegate -- loop )
    dup <game-loop*> ; inline

M: game-loop dispose
    stop-loop ;

USE: vocabs.loader

{ "game.loop" "prettyprint" } "game.loop.prettyprint" require-when
