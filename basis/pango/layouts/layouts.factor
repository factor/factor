! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays alien alien.c-types math destructors accessors
namespaces kernel pango pango.cairo cairo.ffi glib ;
IN: pango.layouts

: layout-dim ( layout -- dim )
    0 <int> 0 <int> [ pango_layout_get_pixel_size ] 2keep
    [ *int ] bi@ 2array ;

ERROR: bad-font name ;

: set-layout-font ( str layout -- )
    swap dup pango_font_description_from_string
    [ ] [ bad-font ] ?if
    &pango_font_description_free
    pango_layout_set_font_description ;

: set-layout-text ( str layout -- )
    -1 pango_layout_set_text ;

: <layout> ( text font cairo -- layout )
    [
        pango_cairo_create_layout |g_object_unref
        [ set-layout-font ] keep
        [ set-layout-text ] keep
    ] with-destructors ;

: dummy-cairo ( -- cr )
    [
        CAIRO_FORMAT_ARGB32 0 0 cairo_image_surface_create
        cairo_create
    ] initialize-alien ;
