! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays sequences math math.order opengl opengl.gl strings ;
IN: ui.text

TUPLE: font name size bold? italic? ;

<PRIVATE

SYMBOL: font-renderer

HOOK: open-font font-renderer ( font -- open-font )

HOOK: string-dim font-renderer ( open-font string -- dim )

HOOK: string-width font-renderer ( open-font string -- w )

HOOK: string-height font-renderer ( open-font string -- h )

M: object string-dim [ string-width ] [ string-height ] 2bi 2array ;

M: object string-width string-dim first ;

M: object string-height string-dim second ;

HOOK: draw-string font-renderer ( font string loc -- )

HOOK: free-fonts font-renderer ( world -- )

: combine-text-dim ( dim1 dim2 -- dim3 )
    [ [ first ] bi@ max ]
    [ [ second ] bi@ + ]
    2bi 2array ;

PRIVATE>

HOOK: x>offset font-renderer ( x font string -- n )

HOOK: offset>x font-renderer ( n font string -- x )

GENERIC: text-dim ( font text -- dim )

M: string text-dim [ open-font ] dip string-dim ;

M: sequence text-dim
    [ { 0 0 } ] [ open-font ] [ ] tri*
    [ string-dim combine-text-dim ] with each ;

: text-width ( font text -- w ) text-dim first ;

: text-height ( font text -- h ) text-dim second ;

GENERIC# draw-text 1 ( font text loc -- )

M: string draw-text draw-string ;

M: sequence draw-text
    [
        [
            2dup { 0 0 } draw-string
            [ open-font ] dip string-height
            0.0 swap 0.0 glTranslated
        ] with each
    ] with-translation ;