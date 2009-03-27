! Copyright (C) 2008 Matthew Willis.
! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
!
! pangocairo bindings, from pango/pangocairo.h
USING: alien alien.syntax combinators system cairo.ffi
alien.libraries ;
IN: pango.cairo

<< {
    { [ os winnt? ] [ "pangocairo" "libpangocairo-1.0-0.dll" "cdecl" add-library ] }
    { [ os macosx? ] [ "pangocairo" "/opt/local/lib/libpangocairo-1.0.0.dylib" "cdecl" add-library ] }
    { [ os unix? ] [ ] }
} cond >>

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
