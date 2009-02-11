! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache colors.constants destructors fry
kernel opengl opengl.gl combinators ;
IN: opengl.texture-cache

TUPLE: texture texture display-list age disposed ;

: make-texture-display-list ( dim texture -- dlist )
    GL_COMPILE [
        GL_TEXTURE_2D [
            GL_TEXTURE_BIT [
                GL_TEXTURE_COORD_ARRAY [
                    COLOR: white gl-color
                    GL_TEXTURE_2D swap glBindTexture
                    init-texture rect-texture-coords
                    fill-rect-vertices (gl-fill-rect)
                    GL_TEXTURE_2D 0 glBindTexture
                ] do-enabled-client-state
            ] do-attribs
        ] do-enabled
    ] make-dlist ;

TUPLE: texture-info dim bitmap format type ;

C: <texture-info> texture-info

: <texture> ( info -- texture )
    [
        { [ dim>> ] [ bitmap>> ] [ format>> ] [ type>> ] }
        cleave make-texture
    ] [ dim>> ] bi
    over make-texture-display-list 0 f texture boa ;

M: texture dispose*
    [ texture>> delete-texture ]
    [ display-list>> delete-dlist ] bi ;

TUPLE: texture-cache renderer cache disposed ;

: <texture-cache> ( renderer -- cache )
    texture-cache new
        swap >>renderer
        <cache-assoc> >>cache ;

GENERIC: render-texture ( key renderer -- texture-info )

: get-texture ( key texture-cache -- dlist )
    dup check-disposed
    [ cache>> ] keep
    '[ _ renderer>> render-texture <texture> ] cache
    display-list>> ;

M: texture-cache dispose*
    cache>> values dispose-each ;

: purge-texture-cache ( texture-cache -- )
    cache>> purge-cache ;