! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays errors freetype generic hashtables
kernel math models namespaces opengl sequences strings ;

: string-width ( open-font string -- w )
    0 -rot [ char-width + ] each-with ;

: text-height ( open-font text -- n )
    dup string? [ drop 1 ] [ length ] if
    swap font-height * ;

: text-width ( open-font text -- n )
    dup string? [
        string-width
    ] [
        0 -rot [ string-width max ] each-with
    ] if ;

: text-dim ( open-font text -- dim )
    [ text-width ] 2keep text-height 2array ;

: font-sprites ( open-font world -- pair )
    world-fonts [ lookup-font V{ } clone 2array ] cache ;

: draw-string ( font string loc -- )
    >r >r world get font-sprites first2 r> r> (draw-string) ;

: draw-text ( font text loc -- )
    over string? [
        draw-string
    ] [
        [
            over open-font font-height -rot [
                >r 2dup r> { 0 0 } draw-string
                0.0 swap 0.0 glTranslated
            ] each 2drop
        ] with-translation
    ] if ;
