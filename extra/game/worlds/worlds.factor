USING: accessors combinators fry game.input game.loop generic kernel math
parser sequences ui ui.gadgets ui.gadgets.worlds ui.gestures threads
words ;
IN: game.worlds

TUPLE: game-world < world
    game-loop
    { tick-slice float initial: 0.0 } ;

GENERIC: tick-interval-micros ( world -- micros )

M: game-world draw*
    swap >>tick-slice relayout-1 yield ;

M: game-world begin-world
    open-game-input 
    dup [ tick-interval-micros ] [ ] bi <game-loop> [ >>game-loop ] keep start-loop
    drop ;

M: game-world end-world
    [ [ stop-loop ] when* f ] change-game-loop
    close-game-input
    drop ;

TUPLE: game-attributes < world-attributes
    { tick-interval-micros fixnum read-only } ;

: verify-game-attributes ( attributes -- )
    world-class>> { f world } member?
    [ "GAME: must be given a custom world-class" throw ] when ;

: define-game-tick-interval-micros ( attributes -- )
    [ world-class>> \ tick-interval-micros create-method ]
    [ tick-interval-micros>> '[ drop _ ] ] bi
    define ;

: define-game-methods ( attributes -- )
    {
        [ verify-game-attributes ]
        [ define-game-tick-interval-micros ]
    } cleave ;

: define-game ( word attributes -- )
    [ [ ] define-main-window ]
    [ nip define-game-methods ] 2bi ;

SYNTAX: GAME:
    CREATE
    game-attributes parse-main-window-attributes
    define-game ;
