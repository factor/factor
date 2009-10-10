! Copyright (C) 2008 Matthew Willis.
! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
!
! pangocairo bindings, from pango/pangocairo.h
USING: arrays sequences alien alien.c-types alien.destructors
alien.libraries alien.syntax math math.functions math.vectors
destructors combinators colors fonts accessors assocs namespaces
kernel pango pango.fonts pango.layouts glib unicode.data images
cache init system math.rectangles fry memoize io.encodings.utf8
classes.struct cairo cairo.ffi ;
IN: pango.cairo

<< {
    { [ os winnt? ] [ "pangocairo" "libpangocairo-1.0-0.dll" "cdecl" add-library ] }
    { [ os macosx? ] [ "pangocairo" "/opt/local/lib/libpangocairo-1.0.0.dylib" "cdecl" add-library ] }
    { [ os unix? ] [ ] }
} cond >>

LIBRARY: pangocairo

C-TYPE: PangoCairoFontMap
C-TYPE: PangoCairoFont

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

TUPLE: layout < disposable font string selection layout metrics ink-rect logical-rect image ;

SYMBOL: dpi

72 dpi set-global

: set-layout-font ( font layout -- )
    swap cache-font-description pango_layout_set_font_description ;

: set-layout-text ( str layout -- )
    #! Replace nulls with something else since Pango uses null-terminated
    #! strings
    swap -1 pango_layout_set_text ;

: layout-extents ( layout -- ink-rect logical-rect )
    PangoRectangle <struct>
    PangoRectangle <struct>
    [ pango_layout_get_extents ] 2keep
    [ PangoRectangle>rect ] bi@ ;

: layout-baseline ( layout -- baseline )
    pango_layout_get_iter &pango_layout_iter_free
    pango_layout_iter_get_baseline
    pango>float ;

: set-foreground ( cr font -- )
    foreground>> set-source-color ;

: fill-background ( cr font dim -- )
    [ background>> set-source-color ]
    [ [ { 0 0 } ] dip <rect> fill-rect ] bi-curry* bi ;

: rect-translate-x ( rect x -- rect' )
    '[ _ 0 2array v- ] change-loc ;

: first-line ( layout -- line )
    layout>> 0 pango_layout_get_line_readonly ;

: line-offset>x ( layout n -- x )
    #! n is an index into the UTF8 encoding of the text
    [ drop first-line ] [ swap string>> >utf8-index ] 2bi
    0 0 <int> [ pango_layout_line_index_to_x ] keep
    *int pango>float ;

: x>line-offset ( layout x -- n )
    #! n is an index into the UTF8 encoding of the text
    [
        [ first-line ] dip
        float>pango 0 <int> 0 <int>
        [ pango_layout_line_x_to_index drop ] 2keep
        [ *int ] bi@ swap
    ] [ drop string>> ] 2bi utf8-index> + ;

: selection-start/end ( selection -- start end )
    selection>> [ start>> ] [ end>> ] bi ;

: selection-rect ( layout -- rect )
    [ ink-rect>> dim>> ] [ ] [ selection-start/end ] tri [ line-offset>x ] bi-curry@ bi
    [ drop nip 0 2array ] [ swap - swap second 2array ] 3bi <rect> ;

: fill-selection-background ( cr layout -- )
    dup selection>> [
        [ selection>> color>> set-source-color ]
        [
            [ selection-rect ] [ ink-rect>> loc>> first ] bi
            rect-translate-x
            fill-rect
        ] 2bi
    ] [ 2drop ] if ;

: text-position ( layout -- loc )
    [ logical-rect>> ] [ ink-rect>> ] bi [ loc>> ] bi@ v- ;

: set-text-position ( cr loc -- )
    first2 cairo_move_to ;

: draw-layout ( layout -- image )
    dup ink-rect>> dim>> [ >fixnum ] map [
        swap {
            [ layout>> pango_cairo_update_layout ]
            [ [ font>> ] [ ink-rect>> dim>> ] bi fill-background ]
            [ fill-selection-background ]
            [ text-position set-text-position ]
            [ font>> set-foreground ]
            [ layout>> pango_cairo_show_layout ]
        } 2cleave
    ] make-bitmap-image ;

: escape-nulls ( str -- str' )
    { { 0 CHAR: zero-width-no-break-space } } substitute ;

: unpack-selection ( layout string/selection -- layout )
    dup selection? [
        [ string>> escape-nulls >>string ] [ >>selection ] bi
    ] [ escape-nulls >>string ] if ; inline

: set-layout-resolution ( layout -- )
    pango_layout_get_context dpi get pango_cairo_context_set_resolution ;

: <PangoLayout> ( text font -- layout )
    dummy-cairo pango_cairo_create_layout |g_object_unref
    [ set-layout-resolution ] keep
    [ set-layout-font ] keep
    [ set-layout-text ] keep ;

: glyph-height ( font string -- y )
    swap <PangoLayout> &g_object_unref layout-extents drop dim>> second ;

MEMO: missing-font-metrics ( font -- metrics )
    #! Pango doesn't provide x-height and cap-height but Core Text does, so we
    #! simulate them on Pango.
    [
        [ metrics new ] dip
        [ "x" glyph-height >>x-height ]
        [ "Y" glyph-height >>cap-height ] bi
    ] with-destructors ;

: layout-metrics ( layout -- metrics )
    dup font>> missing-font-metrics clone
        swap
        [ layout>> layout-baseline >>ascent ]
        [ logical-rect>> dim>> [ first >>width ] [ second >>height ] bi ] bi
        dup [ height>> ] [ ascent>> ] bi - >>descent ;

: <layout> ( font string -- line )
    [
        layout new-disposable
            swap unpack-selection
            swap >>font
            dup [ string>> ] [ font>> ] bi <PangoLayout> >>layout
            dup layout>> layout-extents [ >>ink-rect ] [ >>logical-rect ] bi*
            dup layout-metrics >>metrics
            dup draw-layout >>image
    ] with-destructors ;

M: layout dispose* layout>> g_object_unref ;

SYMBOL: cached-layouts

: cached-layout ( font string -- layout )
    cached-layouts get [ <layout> ] 2cache ;

: cached-line ( font string -- line )
    cached-layout layout>> first-line ;

[ <cache-assoc> cached-layouts set-global ] "pango.cairo" add-init-hook
