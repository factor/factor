! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays sequences math math.order opengl opengl.gl
strings fonts colors accessors namespaces ui.gadgets.worlds ;
IN: ui.text

<PRIVATE

SYMBOL: font-renderer

HOOK: init-text-rendering font-renderer ( world -- )

: world-text-handle ( world -- handle )
    dup text-handle>> [ dup init-text-rendering ] unless
    text-handle>> ;

HOOK: flush-layout-cache font-renderer ( -- )

[ flush-layout-cache ] flush-layout-cache-hook set-global

HOOK: string-dim font-renderer ( font string -- dim )

HOOK: string-width font-renderer ( font string -- w )

HOOK: string-height font-renderer ( font string -- h )

M: object string-dim [ string-width ] [ string-height ] 2bi 2array ;

M: object string-width string-dim first ;

M: object string-height string-dim second ;

HOOK: draw-string font-renderer ( font string -- )

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

HOOK: font-metrics font-renderer ( font -- metrics )

HOOK: line-metrics font-renderer ( font string -- metrics )

GENERIC: draw-text ( font text -- )

M: string draw-text draw-string ;

M: selection draw-text draw-string ;

M: array draw-text
    GL_MODELVIEW [
        [
            [ draw-string ]
            [ [ 0.0 ] 2dip string-height 0.0 glTranslated ] 2bi
        ] with each
    ] do-matrix ;

USING: vocabs.loader namespaces system combinators ;

"ui-backend" get [
    {
        { [ os macosx? ] [ "core-text" ] }
        { [ os windows? ] [ "pango" ] }
        { [ os unix? ] [ "pango" ] }
    } cond
] unless* "ui.text." prepend require