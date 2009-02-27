! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
!
! pangocairo bindings, from pango/pangocairo.h
USING: cairo.ffi alien.c-types math alien.syntax system destructors
memoize accessors kernel combinators alien arrays fonts pango
pango.fonts ;
IN: pango.cairo

<< "pangocairo" {
    { [ os winnt? ] [ "libpangocairo-1.0-0.dll" ] }
    { [ os macosx? ] [ "/opt/local/lib/libpangocairo-1.0.0.dylib" ] }
    { [ os unix? ] [ "libpangocairo-1.0.so" ] }
} cond "cdecl" add-library >>

LIBRARY: pangocairo

FUNCTION: PangoFontMap*
pango_cairo_font_map_new ( ) ;

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

MEMO: (cache-font) ( font -- open-font )
    [ pango_cairo_font_map_get_default dummy-pango-context ] dip
    cache-font-description
    pango_font_map_load_font ;

: cache-font ( font -- open-font )
    strip-font-colors (cache-font) ;

: get-font-metrics ( font -- metrics )
    (cache-font) f pango_font_get_metrics &pango_font_metrics_unref ;

: parse-font-metrics ( metrics -- metrics' )
    [ metrics new ] dip
    {
        [ pango_font_metrics_get_ascent PANGO_SCALE /f >>height ]
        [ pango_font_metrics_get_descent PANGO_SCALE /f >>descent ]
        [ drop 0 >>leading ]
        [ drop 0 >>cap-height ]
        [ drop 0 >>x-height ]
    } cleave
    dup [ height>> ] [ descent>> ] bi - >>ascent ;

MEMO: (cache-font-metrics) ( font -- metrics )
    [ get-font-metrics parse-font-metrics ] with-destructors ;

: cache-font-metrics ( font -- metrics )
    strip-font-colors (cache-font-metrics) ;
