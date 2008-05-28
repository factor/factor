! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
!
! pangocairo bindings, from pango/pangocairo.h
USING: cairo.ffi alien.c-types math
alien.syntax system combinators alien
pango pango.fonts ;
IN: cairo.pango

<< "pangocairo" {
!    { [ os winnt? ] [ "libpangocairo-1.dll" ] }
!    { [ os macosx? ] [ "libpangocairo.dylib" ] }
    { [ os unix? ] [ "libpangocairo-1.0.so" ] }
} cond "cdecl" add-library >>

LIBRARY: pangocairo

FUNCTION: PangoFontMap*
pango_cairo_font_map_new  ( ) ;

FUNCTION: PangoFontMap*
pango_cairo_font_map_new_for_font_type ( cairo_font_type_t fonttype ) ;

FUNCTION: PangoFontMap*
pango_cairo_font_map_get_default ( ) ;

FUNCTION: cairo_font_type_t
pango_cairo_font_map_get_font_type ( PangoCairoFontMap* fontmap ) ;

FUNCTION: void
pango_cairo_font_map_set_resolution ( PangoCairoFontMap* fontmap, double dpi ) ;

FUNCTION: double
pango_cairo_font_map_get_resolution ( PangoCairoFontMap* fontmap ) ;

FUNCTION: PangoContext*
pango_cairo_font_map_create_context ( PangoCairoFontMap* fontmap ) ;

FUNCTION: cairo_scaled_font_t*
pango_cairo_font_get_scaled_font ( PangoCairoFont* font ) ;

! Update a Pango context for the current state of a cairo context
FUNCTION: void
pango_cairo_update_context ( cairo_t* cr, PangoContext* context ) ;

FUNCTION: void
pango_cairo_context_set_font_options ( PangoContext* context, cairo_font_options_t* options ) ;

FUNCTION: cairo_font_options_t*
pango_cairo_context_get_font_options ( PangoContext* context ) ;

FUNCTION: void
pango_cairo_context_set_resolution ( PangoContext* context, double dpi ) ;

FUNCTION: double
pango_cairo_context_get_resolution ( PangoContext* context ) ;

! Convenience
FUNCTION: PangoLayout*
pango_cairo_create_layout ( cairo_t* cr ) ;

FUNCTION: void
pango_cairo_update_layout ( cairo_t* cr, PangoLayout* layout ) ;

! Rendering
FUNCTION: void
pango_cairo_show_glyph_string ( cairo_t* cr, PangoFont* font, PangoGlyphString* glyphs ) ;

FUNCTION: void
pango_cairo_show_layout_line ( cairo_t* cr, PangoLayoutLine* line ) ;

FUNCTION: void
pango_cairo_show_layout ( cairo_t* cr, PangoLayout* layout ) ;

FUNCTION: void
pango_cairo_show_error_underline ( cairo_t* cr, double x, double y, double width, double height ) ;

! Rendering to a path
FUNCTION: void
pango_cairo_glyph_string_path ( cairo_t* cr, PangoFont* font, PangoGlyphString* glyphs ) ;

FUNCTION: void
pango_cairo_layout_line_path  ( cairo_t* cr, PangoLayoutLine* line ) ;

FUNCTION: void
pango_cairo_layout_path ( cairo_t* cr, PangoLayout* layout ) ;

FUNCTION: void
pango_cairo_error_underline_path ( cairo_t* cr, double x, double y, double width, double height ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Higher level words and combinators
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: destructors accessors namespaces kernel cairo ;

TUPLE: pango-layout alien ;
C: <pango-layout> pango-layout
M: pango-layout dispose ( alien -- ) alien>> g_object_unref ;

: layout ( -- pango-layout ) pango-layout get ;

: (with-pango) ( layout quot -- )
    >r alien>> pango-layout r> with-variable ; inline

: with-pango ( quot -- )
    cr pango_cairo_create_layout <pango-layout> swap
    [ (with-pango) ] curry with-disposal ; inline

: pango-layout-get-pixel-size ( layout -- width height )
    0 <int> 0 <int> [ pango_layout_get_pixel_size ] 2keep
    [ *int ] bi@ ;

: dummy-pango ( quot -- )
    >r CAIRO_FORMAT_ARGB32 0 0 cairo_image_surface_create
    r> [ with-pango ] curry with-cairo-from-surface ; inline

: layout-size ( quot -- width height )
    [ layout pango-layout-get-pixel-size ] compose dummy-pango ; inline

: layout-font ( str -- )
    pango_font_description_from_string
    dup zero? [ "pango: not a valid font." throw ] when
    layout over pango_layout_set_font_description
    pango_font_description_free ;

: layout-text ( str -- )
    layout swap -1 pango_layout_set_text ;

: families ( -- families )
    pango_cairo_font_map_get_default list-families ;
