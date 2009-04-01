! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types assocs cache kernel math math.vectors
namespaces opengl.textures pango.cairo pango.layouts ui.gadgets.worlds
ui.text ui.text.private pango sequences ;
IN: ui.text.pango

SINGLETON: pango-renderer

M: pango-renderer init-text-rendering
    <cache-assoc> >>text-handle drop ;

M: pango-renderer string-dim
    [ " " string-dim { 0 1 } v* ]
    [ cached-layout logical-rect>> dim>> [ >integer ] map ] if-empty ;

M: pango-renderer flush-layout-cache
    cached-layouts get purge-cache ;

: rendered-layout ( font string -- texture )
    world get world-text-handle
    [ cached-layout [ image>> ] [ text-position vneg ] bi <texture> ]
    2cache ;

M: pango-renderer draw-string ( font string -- )
    rendered-layout draw-texture ;

M: pango-renderer x>offset ( x font string -- n )
    cached-layout swap x>line-offset ;

M: pango-renderer offset>x ( n font string -- x )
    cached-layout swap line-offset>x ;

M: pango-renderer font-metrics ( font -- metrics )
    " " cached-layout metrics>> clone f >>width ;

M: pango-renderer line-metrics ( font string -- metrics )
    [ " " line-metrics clone 0 >>width ]
    [ cached-layout metrics>> ]
    if-empty ;

pango-renderer font-renderer set-global