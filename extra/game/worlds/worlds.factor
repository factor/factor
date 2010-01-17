! (c)2009 Joe Groff bsd license
USING: accessors combinators fry game.input game.loop generic kernel math
parser sequences ui ui.gadgets ui.gadgets.worlds ui.gestures threads
words ;
IN: game.worlds

TUPLE: game-world < world
    game-loop
    { tick-slice float initial: 0.0 } ;

GENERIC: tick-interval-micros ( world -- micros )

GENERIC: begin-game-world ( world -- )
M: object begin-game-world drop ;

GENERIC: end-game-world ( world -- )
M: object end-game-world drop ;

M: game-world draw*
    swap >>tick-slice relayout-1 yield ;

M: game-world begin-world
    open-game-input 
    dup begin-game-world
    dup [ tick-interval-micros ] [ ] bi <game-loop> [ >>game-loop ] keep start-loop
    drop ;

M: game-world end-world
    [ [ stop-loop ] when* f ] change-game-loop
    end-game-world
    close-game-input ;

TUPLE: game-attributes < world-attributes
    { tick-interval-micros fixnum read-only } ;

<PRIVATE

: verify-game-attributes ( attributes -- )
    {
        [
            world-class>> { f world } member?
            [ "GAME: must be given a custom world-class" throw ] when
        ]
        [
            tick-interval-micros>> 0 <=
            [ "GAME: must be given a nonzero tick-interval-micros" throw ] when
        ]
    } cleave ;

: define-game-tick-interval-micros ( attributes -- )
    [ world-class>> \ tick-interval-micros create-method ]
    [ tick-interval-micros>> '[ drop _ ] ] bi
    define ;

: define-game-methods ( attributes -- )
    {
        [ verify-game-attributes ]
        [ define-game-tick-interval-micros ]
    } cleave ;

: define-game ( word attributes quot -- )
    [ define-main-window ]
    [ drop nip define-game-methods ] 3bi ;

PRIVATE>

SYNTAX: GAME:
    CREATE
    game-attributes parse-main-window-attributes
    parse-definition
    define-game ;
