! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache colors.constants destructors fry
kernel locals opengl opengl.gl ;
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

:: <texture> ( dim bitmap format type -- texture )
    dim bitmap format type make-texture
    dim over make-texture-display-list 0 f texture boa ;

M: texture dispose*
    [ texture>> delete-texture ]
    [ display-list>> delete-dlist ] bi ;

TUPLE: texture-cache format type renderer cache disposed ;

: <texture-cache> ( -- cache )
    texture-cache new
        <cache-assoc> >>cache ;

GENERIC: render-texture ( key renderer -- dim bitmap )

: get-texture ( key texture-cache -- dlist )
    dup check-disposed
    [ cache>> ] keep
    '[
        _
        [ renderer>> render-texture ]
        [ format>> ]
        [ type>> ]
        tri <texture>
    ] cache
    display-list>> ;

M: texture-cache dispose*
    cache>> values dispose-each ;

: purge-texture-cache ( texture-cache -- )
    cache>> purge-cache ;