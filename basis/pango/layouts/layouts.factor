! Copyright (C) 2008 Matthew Willis.
! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays alien alien.c-types alien.syntax math destructors accessors assocs
namespaces kernel pango pango.fonts pango.cairo cairo.ffi glib unicode.data ;
IN: pango.layouts

LIBRARY: pango

FUNCTION: PangoLayout*
pango_layout_new ( PangoContext* context ) ;

FUNCTION: void
pango_layout_set_text ( PangoLayout* layout, char* text, int length ) ;

FUNCTION: char*
pango_layout_get_text ( PangoLayout* layout ) ;

FUNCTION: void
pango_layout_get_size ( PangoLayout* layout, int* width, int* height ) ;

FUNCTION: void
pango_layout_set_font_description ( PangoLayout* layout, PangoFontDescription* desc ) ;

FUNCTION: PangoFontDescription*
pango_layout_get_font_description ( PangoLayout* layout ) ;

FUNCTION: void
pango_layout_get_pixel_size ( PangoLayout* layout, int* width, int* height ) ;

FUNCTION: int
pango_layout_get_baseline ( PangoLayout* layout ) ;

FUNCTION: void
pango_layout_get_pixel_extents ( PangoLayout *layout, PangoRectangle *ink_rect, PangoRectangle *logical_rect ) ;

: layout-dim ( layout -- dim )
    0 <int> 0 <int> [ pango_layout_get_pixel_size ] 2keep
    [ *int ] bi@ 2array ;

ERROR: bad-font name ;

: set-layout-font ( str layout -- )
    swap cache-font-description pango_layout_set_font_description ;

: set-layout-text ( str layout -- )
    #! Replace nulls with something else since Pango uses null-terminated
    #! strings
    swap { { 0 CHAR: zero-width-no-break-space } } substitute
    -1 pango_layout_set_text ;

: <layout> ( text font cairo -- layout )
    [
        pango_cairo_create_layout |g_object_unref
        [ set-layout-font ] keep
        [ set-layout-text ] keep
    ] with-destructors ;

: dummy-cairo ( -- cr )
    \ dummy-cairo [
        CAIRO_FORMAT_ARGB32 0 0 cairo_image_surface_create
        cairo_create
    ] initialize-alien ;
