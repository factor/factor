! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors audio.engine combinators concurrency.promises
destructors game.input game.loop kernel math parser sequences
threads ui ui.gadgets ui.gadgets.worlds vocabs.parser
words.constant ;
IN: game.worlds

TUPLE: game-world < world
    game-loop
    audio-engine
    { tick-interval-nanos integer }
    { use-game-input? boolean }
    { use-audio-engine? boolean }
    { audio-engine-device initial: f }
    { audio-engine-voice-count initial: 16 }
    { tick-slice float initial: 0.0 } ;

GENERIC: begin-game-world ( world -- )
M: object begin-game-world drop ;

GENERIC: end-game-world ( world -- )
M: object end-game-world drop ;

GENERIC: tick-game-world ( world -- )
M: object tick-game-world drop ;

M: game-world tick*
    [ tick-game-world ]
    [ audio-engine>> [ update-audio ] when* ] bi ;

M: game-world draw*
    swap >>tick-slice relayout-1 yield ;

<PRIVATE

: open-game-audio-engine ( game-world -- audio-engine )
    {
        [ audio-engine-device>> ]
        [ audio-engine-voice-count>> ]
    } cleave <audio-engine>
    [ start-audio* ] keep ; inline

PRIVATE>

M: game-world begin-world
    dup use-game-input?>> [ open-game-input ] when
    dup use-audio-engine?>> [ dup open-game-audio-engine >>audio-engine ] when
    dup [ tick-interval-nanos>> ] [ ] bi <game-loop>
    [ >>game-loop begin-game-world ] keep start-loop ;

M: game-world end-world
    dup game-loop>> [ stop-loop ] when*
    [ end-game-world ]
    [ audio-engine>> [ dispose ] when* ]
    [ use-game-input?>> [ close-game-input ] when ] tri ;

TUPLE: game-attributes < world-attributes
    { tick-interval-nanos integer }
    { use-game-input? boolean initial: f }
    { use-audio-engine? boolean initial: f }
    { audio-engine-device initial: f }
    { audio-engine-voice-count initial: 16 } ;

M: game-world apply-world-attributes
    {
        [ tick-interval-nanos>> >>tick-interval-nanos ]
        [ use-game-input?>> >>use-game-input? ]
        [ use-audio-engine?>> >>use-audio-engine? ]
        [ audio-engine-device>> >>audio-engine-device ]
        [ audio-engine-voice-count>> >>audio-engine-voice-count ]
        [ call-next-method ]
    } cleave ;

: start-game ( attributes -- game-world )
    f swap open-window* ;

: wait-game ( attributes -- game-world )
    f swap open-window* dup promise>> ?promise drop ;

: define-attributes-word ( word tuple -- )
    [ name>> "-attributes" append create-word-in ] dip define-constant ;

SYNTAX: GAME:
    scan-new-word
    game-attributes parse-window-attributes
    2dup define-attributes-word
    parse-definition
    [ define-window ] [ 2drop current-vocab main<< ] 3bi ;
