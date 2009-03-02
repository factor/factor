! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types assocs cache kernel math math.vectors
namespaces opengl.textures pango.cairo pango.layouts ui.gadgets.worlds
ui.text ui.text.private pango ;
IN: ui.text.pango

SINGLETON: pango-renderer

M: pango-renderer init-text-rendering
    <cache-assoc> >>text-handle drop ;

M: pango-renderer string-dim cached-layout logical-rect>> dim>> ;

M: pango-renderer finish-text-rendering
    text-handle>> purge-cache
    cached-layouts get purge-cache ;

: rendered-layout ( font string -- texture )
    world get text-handle>>
    [ cached-layout [ image>> ] [ text-position vneg ] bi <texture> ]
    2cache ;

M: pango-renderer draw-string ( font string -- )
    rendered-layout draw-texture ;

M: pango-renderer x>offset ( x font string -- n )
    cached-line swap x>line-offset ;

M: pango-renderer offset>x ( n font string -- x )
    cached-line swap line-offset>x ;

M: pango-renderer font-metrics ( font -- metrics )
    "" cached-layout metrics>> clone f >>width ;

M: pango-renderer line-metrics ( font string -- metrics )
    cached-layout metrics>> ;

pango-renderer font-renderer set-global