! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors alien core-graphics.types core-text kernel
namespaces sequences ui.gadgets.worlds ui.render opengl opengl.gl ;
IN: ui.cocoa.text

SINGLETON: core-text-renderer

CONSTANT: font-names
    H{
        { "monospace" "Monaco" }
        { "sans-serif" "Helvetica" }
        { "serif" "Times" }
    }

USING: classes.algebra unicode.case.private ;

: font-name/size ( font -- name size )
    [ first font-names at-default ] [ third ] bi ;

M: core-text-renderer open-font
    dup alien? [ font-name/size cached-font ] unless ;

: string-dim ( open-font string -- dim )
    swap cached-line dim>> ;

M: core-text-renderer string-width ( open-font string -- w )
    string-dim first ;
 
M: core-text-renderer string-height ( open-font string -- h )
    [ " " ] when-empty string-dim second ;

TUPLE: line-texture line texture age ;

: <line-texture> ( line -- texture )
    dup [ dim>> ] [ bitmap>> ] bi GL_RGBA make-texture
    0 \ line-texture boa ;

: line-texture ( string open-font -- texture )
    world get fonts>> [ cached-line <line-texture> ] 2cache ;

: draw-line-texture ( line-texture -- )
    GL_TEXTURE_2D [
        GL_TEXTURE_BIT [
            GL_TEXTURE_COORD_ARRAY [
                GL_TEXTURE_2D over texture>> glBindTexture
                init-texture rect-texture-coords
                line>> dim>> fill-rect-vertices (gl-fill-rect)
                GL_TEXTURE_2D 0 glBindTexture
            ] do-enabled-client-state
        ] do-attribs
    ] do-enabled ;

M: core-text-renderer draw-string ( font string loc -- )
    [ swap open-font line-texture draw-line-texture ] with-translation ;

M: core-text-renderer x>offset ( x font string -- n )
    swap cached-line swap 0 <CGPoint> CTLineGetStringIndexForPosition ;

core-text-renderer font-renderer set-global