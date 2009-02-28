! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types assocs cache kernel math
namespaces opengl.textures pango.cairo pango.layouts
ui.gadgets.worlds ui.text ui.text.private ;
IN: ui.text.pango

SINGLETON: pango-renderer

M: pango-renderer init-text-rendering
    <cache-assoc> >>text-handle drop ;

M: pango-renderer string-dim cached-layout dim>> ;

M: pango-renderer finish-text-rendering
    text-handle>> purge-cache
    cached-layouts get purge-cache ;

: rendered-layout ( font string -- texture )
    world get text-handle>>
    [ cached-layout [ image>> ] [ loc>> ] bi <texture> ]
    2cache ;

M: pango-renderer draw-string ( font string -- )
    rendered-layout draw-texture ;

M: pango-renderer x>offset ( x font string -- n )
    cached-line swap 0 <int> 0 <int>
    [ pango_layout_line_x_to_index drop ] 2keep
    [ *int ] bi@ + ;

M: pango-renderer offset>x ( n font string -- x )
    cached-line swap f
    0 <int> [ pango_layout_line_index_to_x ] keep *int ;

: missing-metrics ( metrics -- metrics ) 5 >>cap-height 5 >>x-height ;

M: pango-renderer font-metrics ( font -- metrics )
    cache-font-metrics missing-metrics ;

M: pango-renderer line-metrics ( font string -- metrics )
    cached-layout metrics>> missing-metrics ;

pango-renderer font-renderer set-global