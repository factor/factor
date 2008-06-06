USING: alien alien.c-types 
math
destructors accessors namespaces
pango kernel ;
IN: pango.layouts

: pango-layout-get-pixel-size ( layout -- width height )
    0 <int> 0 <int> [ pango_layout_get_pixel_size ] 2keep
    [ *int ] bi@ ;

TUPLE: pango-layout alien ;
C: <pango-layout> pango-layout
M: pango-layout dispose ( alien -- ) alien>> g_object_unref ;

: layout ( -- pango-layout ) pango-layout get ;

: (with-layout) ( pango-layout quot -- )
    >r alien>> pango-layout r> with-variable ; inline

: with-layout ( layout quot -- )
    >r <pango-layout> r> [ (with-layout) ] curry with-disposal ; inline

: layout-font ( str -- )
    pango_font_description_from_string
    dup zero? [ "pango: not a valid font." throw ] when
    layout over pango_layout_set_font_description
    pango_font_description_free ;

: layout-text ( str -- )
    layout swap -1 pango_layout_set_text ;
