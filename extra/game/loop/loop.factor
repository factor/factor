USING: accessors calendar continuations destructors kernel math
math.order namespaces system threads ui ui.gadgets.worlds
sequences ;
IN: game.loop

TUPLE: game-loop
    { tick-length integer read-only }
    delegate
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

: since-last-tick ( loop -- milliseconds )
    last-tick>> millis swap - ;

: tick-slice ( loop -- slice )
    [ since-last-tick ] [ tick-length>> ] bi /f 1.0 min ;

CONSTANT: MAX-FRAMES-TO-SKIP 5

DEFER: stop-loop

TUPLE: game-loop-error game-loop error ;

: ?ui-error ( error -- )
    ui-running? [ ui-error ] [ rethrow ] if ;

: game-loop-error ( game-loop error -- )
    [ drop stop-loop ] [ \ game-loop-error boa ?ui-error ] 2bi ;

<PRIVATE

: redraw ( loop -- )
    [ 1 + ] change-frame-number
    [ tick-slice ] [ delegate>> ] bi draw* ;

: tick ( loop -- )
    delegate>> tick* ;

: increment-tick ( loop -- )
    [ 1 + ] change-tick-number
    dup tick-length>> [ + ] curry change-last-tick
    drop ;

: ?tick ( loop count -- )
    [ millis >>last-tick drop ] [
        over [ since-last-tick ] [ tick-length>> ] bi >=
        [ [ drop increment-tick ] [ drop tick ] [ 1 - ?tick ] 2tri ]
        [ 2drop ] if
    ] if-zero ;

: (run-loop) ( loop -- )
    dup running?>>
    [ [ MAX-FRAMES-TO-SKIP ?tick ] [ redraw ] [ 1 milliseconds sleep (run-loop) ] tri ]
    [ drop ] if ;

: run-loop ( loop -- )
    dup game-loop
    [ [ (run-loop) ] [ game-loop-error ] recover ]
    with-variable ;

: benchmark-millis ( loop -- millis )
    millis swap benchmark-time>> - ;

PRIVATE>

: reset-loop-benchmark ( loop -- )
    millis >>benchmark-time
    dup tick-number>> >>benchmark-tick-number
    dup frame-number>> >>benchmark-frame-number
    drop ;

: benchmark-ticks-per-second ( loop -- n )
    [ tick-number>> ] [ benchmark-tick-number>> - ] [ benchmark-millis ] tri /f ;
: benchmark-frames-per-second ( loop -- n )
    [ frame-number>> ] [ benchmark-frame-number>> - ] [ benchmark-millis ] tri /f ;

: start-loop ( loop -- )
    millis >>last-tick
    t >>running?
    [ reset-loop-benchmark ]
    [ [ run-loop ] curry "game loop" spawn ]
    [ (>>thread) ] tri ;

: stop-loop ( loop -- )
    f >>running?
    f >>thread
    drop ;

: <game-loop> ( tick-length delegate -- loop )
    millis f f 0 0 millis 0 0
    game-loop boa ;

M: game-loop dispose
    stop-loop ;

USING: vocabs vocabs.loader ;

"prettyprint" vocab [ "game.loop.prettyprint" require ] when
