! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays sequences math math.order opengl opengl.gl
strings fonts colors accessors ;
IN: ui.text

<PRIVATE

SYMBOL: font-renderer

HOOK: finish-text-rendering font-renderer ( world -- )

M: object finish-text-rendering drop ;

HOOK: string-dim font-renderer ( font string -- dim )

HOOK: string-width font-renderer ( font string -- w )

HOOK: string-height font-renderer ( font string -- h )

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

M: string text-dim string-dim ;

M: array text-dim
    [ { 0 0 } ] 2dip [ string-dim combine-text-dim ] with each ;

: text-width ( font text -- w ) text-dim first ;

: text-height ( font text -- h ) text-dim second ;

HOOK: line-metrics font-renderer ( font string -- metrics )

GENERIC# draw-text 1 ( font text loc -- )

M: string draw-text draw-string ;

M: selection draw-text draw-string ;

M: array draw-text
    [
        [
            2dup { 0 0 } draw-string
            0.0 swap string-height 0.0 glTranslated
        ] with each
    ] with-translation ;