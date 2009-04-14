! Copyright (C) 2008 Matthew Willis.
! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays sequences alien alien.c-types alien.destructors
alien.syntax math math.functions math.vectors destructors combinators
colors fonts accessors assocs namespaces kernel pango pango.fonts
pango.cairo cairo cairo.ffi glib unicode.data images cache init
math.rectangles fry memoize io.encodings.utf8 ;
IN: pango.layouts

LIBRARY: pango

FUNCTION: PangoLayout*
pango_layout_new ( PangoContext* context ) ;

FUNCTION: PangoContext*
pango_layout_get_context ( PangoLayout* layout ) ;

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

FUNCTION: void
pango_layout_get_extents ( PangoLayout* layout, PangoRectangle* ink_rect, PangoRectangle* logical_rect ) ;

FUNCTION: void
pango_layout_get_pixel_extents ( PangoLayout* layout, PangoRectangle* ink_rect, PangoRectangle* logical_rect ) ;

FUNCTION: PangoLayoutLine*
pango_layout_get_line_readonly ( PangoLayout* layout, int line ) ;
                                                         
FUNCTION: void
pango_layout_line_index_to_x ( PangoLayoutLine* line, int index_, uint trailing, int* x_pos ) ;

FUNCTION: gboolean
pango_layout_line_x_to_index ( PangoLayoutLine* line, int x_pos, int* index_, int* trailing ) ;

FUNCTION: PangoLayoutIter*
pango_layout_get_iter ( PangoLayout* layout ) ;

FUNCTION: int
pango_layout_iter_get_baseline ( PangoLayoutIter* iter ) ;

FUNCTION: void
pango_layout_iter_free ( PangoLayoutIter* iter ) ;

DESTRUCTOR: pango_layout_iter_free

TUPLE: layout font string selection layout metrics ink-rect logical-rect image disposed ;

SYMBOL: dpi

72 dpi set-global

: set-layout-font ( font layout -- )
    swap cache-font-description pango_layout_set_font_description ;

: set-layout-text ( str layout -- )
    #! Replace nulls with something else since Pango uses null-terminated
    #! strings
    swap -1 pango_layout_set_text ;

: set-layout-resolution ( layout -- )
    pango_layout_get_context dpi get pango_cairo_context_set_resolution ;

: <PangoLayout> ( text font -- layout )
    dummy-cairo pango_cairo_create_layout |g_object_unref
    [ set-layout-resolution ] keep
    [ set-layout-font ] keep
    [ set-layout-text ] keep ;

: layout-extents ( layout -- ink-rect logical-rect )
    "PangoRectangle" <c-object>
    "PangoRectangle" <c-object>
    [ pango_layout_get_extents ] 2keep
    [ PangoRectangle>rect ] bi@ ;

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

: layout-metrics ( layout -- metrics )
    dup font>> missing-font-metrics clone
        swap
        [ layout>> layout-baseline >>ascent ]
        [ logical-rect>> dim>> [ first >>width ] [ second >>height ] bi ] bi
        dup [ height>> ] [ ascent>> ] bi - >>descent ;

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

: <layout> ( font string -- line )
    [
        layout new
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

[ <cache-assoc> cached-layouts set-global ] "pango.layouts" add-init-hook
