! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache colors.constants destructors fry
opengl.textures kernel ;
IN: opengl.texture-cache

TUPLE: texture-cache renderer cache disposed ;

: <texture-cache> ( renderer -- cache )
    texture-cache new
        swap >>renderer
        <cache-assoc> >>cache ;

GENERIC: render-texture ( key renderer -- image )

: get-texture ( key texture-cache -- texture )
    dup check-disposed
    [ cache>> ] keep
    '[ _ renderer>> render-texture <texture> ] cache ;

M: texture-cache dispose*
    cache>> values dispose-each ;

: purge-texture-cache ( texture-cache -- )
    cache>> purge-cache ;