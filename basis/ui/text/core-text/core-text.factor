! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors alien core-graphics.types core-text
core-text.fonts kernel hashtables namespaces sequences
ui.gadgets.worlds ui.text ui.text.private opengl opengl.gl
opengl.texture-cache destructors combinators core-foundation
core-foundation.strings math math.vectors init colors colors.constants
cache arrays ;
IN: ui.text.core-text

SINGLETON: core-text-renderer

M: core-text-renderer init-text-rendering
    core-text-renderer <texture-cache> >>text-handle drop ;

M: core-text-renderer string-dim
    [ " " string-dim { 0 1 } v* ] [ cached-line dim>> ] if-empty ;

M: core-text-renderer render-texture
    drop first2 cached-line
    [ dim>> ] [ bitmap>> ] bi
    GL_BGRA_EXT GL_UNSIGNED_INT_8_8_8_8_REV
    <texture-info> ;

M: core-text-renderer finish-text-rendering
    text-handle>> purge-texture-cache
    cached-lines get purge-cache ;

: rendered-line ( font string -- display-list )
    2array world get text-handle>> get-texture ;

M: core-text-renderer draw-string ( font string -- )
    rendered-line glCallList ;

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

core-text-renderer font-renderer set-global