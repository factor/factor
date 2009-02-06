! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors alien core-graphics.types core-text
core-text.fonts kernel hashtables namespaces sequences
ui.gadgets.worlds ui.text ui.text.private opengl opengl.gl destructors
combinators core-foundation core-foundation.strings memoize math
math.vectors init colors colors.constants ;
IN: ui.text.core-text

SINGLETON: core-text-renderer

M: core-text-renderer string-dim
    [ " " string-dim { 0 1 } v* ] [ cached-line dim>> ] if-empty ;

TUPLE: rendered-line line texture display-list age disposed ;

: make-line-display-list ( line texture -- dlist )
    GL_COMPILE [
        GL_TEXTURE_2D [
            GL_TEXTURE_BIT [
                GL_TEXTURE_COORD_ARRAY [
                    COLOR: white gl-color
                    GL_TEXTURE_2D swap glBindTexture
                    init-texture rect-texture-coords
                    dim>> fill-rect-vertices (gl-fill-rect)
                    GL_TEXTURE_2D 0 glBindTexture
                ] do-enabled-client-state
            ] do-attribs
        ] do-enabled
    ] make-dlist ;

: make-core-graphics-texture ( dim bitmap -- texture )
    GL_BGRA_EXT GL_UNSIGNED_INT_8_8_8_8_REV make-texture ;

: <rendered-line> ( line -- texture )
    #! Note: we only ref-line if make-texture and make-line-display-list
    #! succeed
    [
        dup [ dim>> ] [ bitmap>> ] bi make-core-graphics-texture
        2dup make-line-display-list
        0 f \ rendered-line boa
    ] keep ref-line ;

M: rendered-line dispose*
    [ line>> unref-line ]
    [ texture>> delete-texture ]
    [ display-list>> delete-dlist ] tri ;

: rendered-line ( font string -- rendered-line )
    world get fonts>>
    [ cached-line <rendered-line> ] 2cache 0 >>age ;

: age-rendered-lines ( world -- )
    [ [ age ] age-assoc ] change-fonts drop ;

M: core-text-renderer finish-text-rendering
    age-rendered-lines age-lines ;

M: core-text-renderer draw-string ( font string loc -- )
    [
        rendered-line display-list>> glCallList
    ] with-translation ;

M: core-text-renderer x>offset ( x font string -- n )
    [ 2drop 0 ] [
        cached-line line>>
        swap 0 <CGPoint> CTLineGetStringIndexForPosition
    ] if-empty ;

M: core-text-renderer offset>x ( n font string -- x )
    cached-line line>> swap f
    CTLineGetOffsetForStringIndex ;

M: core-text-renderer line-metrics ( font string -- metrics )
    [ " " line-metrics clone 0 >>width ]
    [ cached-line metrics>> ]
    if-empty ;

M: core-text-renderer free-fonts ( fonts -- )
    values dispose-each ;

core-text-renderer font-renderer set-global