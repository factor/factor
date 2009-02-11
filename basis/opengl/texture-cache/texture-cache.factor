! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache colors.constants destructors fry
kernel opengl opengl.gl combinators ;
IN: opengl.texture-cache

TUPLE: texture texture display-list disposed ;

: make-texture-display-list ( dim texture -- dlist )
    GL_COMPILE [ draw-textured-rect ] make-dlist ;

TUPLE: texture-info dim bitmap format type ;

C: <texture-info> texture-info

: <texture> ( info -- texture )
    [
        { [ dim>> ] [ bitmap>> ] [ format>> ] [ type>> ] }
        cleave make-texture
    ] [ dim>> ] bi
    over make-texture-display-list f texture boa ;

M: texture dispose*
    [ texture>> delete-texture ]
    [ display-list>> delete-dlist ] bi ;

TUPLE: texture-cache renderer cache disposed ;

: <texture-cache> ( renderer -- cache )
    texture-cache new
        swap >>renderer
        <cache-assoc> >>cache ;

GENERIC: render-texture ( key renderer -- texture-info )

: get-texture ( key texture-cache -- texture )
    dup check-disposed
    [ cache>> ] keep
    '[ _ renderer>> render-texture <texture> ] cache ;

M: texture-cache dispose*
    cache>> values dispose-each ;

: purge-texture-cache ( texture-cache -- )
    cache>> purge-cache ;