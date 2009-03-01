! Copyright (C) 2008 Matthew Willis.
! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays sequences alien alien.c-types alien.destructors
alien.syntax math math.functions math.vectors destructors combinators
colors fonts accessors assocs namespaces kernel pango pango.fonts
pango.cairo cairo cairo.ffi glib unicode.data images cache init
math.rectangles fry ;
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
pango_layout_get_pixel_extents ( PangoLayout* layout, PangoRectangle* ink_rect, PangoRectangle* logical_rect ) ;

FUNCTION: PangoLayoutLine*
pango_layout_get_line_readonly ( PangoLayout* layout, int line ) ;
                                                         
FUNCTION: void
pango_layout_line_index_to_x ( PangoLayoutLine* line, int index_, gboolean trailing, int* x_pos ) ;

FUNCTION: gboolean
pango_layout_line_x_to_index ( PangoLayoutLine* line, int x_pos, int* index_, int* trailing ) ;

FUNCTION: PangoLayoutIter*
pango_layout_get_iter ( PangoLayout* layout ) ;

FUNCTION: int
pango_layout_iter_get_baseline ( PangoLayoutIter* iter ) ;

FUNCTION: void
pango_layout_iter_free ( PangoLayoutIter* iter ) ;

DESTRUCTOR: pango_layout_iter_free

TUPLE: layout font string layout metrics ink-rect logical-rect image disposed ;

: layout-dim ( layout -- dim )
    0 <int> 0 <int> [ pango_layout_get_pixel_size ] 2keep
    [ *int ] bi@ 2array ;

: layout-extents ( layout -- ink-rect logical-rect )
    "PangoRectangle" <c-object>
    "PangoRectangle" <c-object>
    [ pango_layout_get_pixel_extents ] 2keep
    [ PangoRectangle>rect ] bi@ ;

: layout-baseline ( layout -- baseline )
    pango_layout_get_iter &pango_layout_iter_free
    pango_layout_iter_get_baseline
    pango>float ;

: set-layout-font ( str layout -- )
    swap pango_layout_set_font_description ;

: set-layout-text ( str layout -- )
    #! Replace nulls with something else since Pango uses null-terminated
    #! strings
    swap
    dup selection? [ string>> ] when
    { { 0 CHAR: zero-width-no-break-space } } substitute
    -1 pango_layout_set_text ;

: <PangoLayout> ( text font -- layout )
    dummy-cairo pango_cairo_create_layout |g_object_unref
    [ set-layout-font ] keep
    [ set-layout-text ] keep ;

: set-foreground ( cr font -- )
    foreground>> set-source-color ;

: fill-background ( cr font dim -- )
    [ background>> set-source-color ]
    [ [ { 0 0 } ] dip <rect> fill-rect ] bi-curry* bi ;

: rect-translate-x ( rect x -- rect' )
    '[ _ 0 2array v- ] change-loc ;

: first-line ( layout -- line )
    0 pango_layout_get_line_readonly ;

: line-offset>x ( line n -- x )
    f 0 <int> [ pango_layout_line_index_to_x ] keep
    *int pango>float ;

: x>line-offset ( line x -- n )
    float>pango 0 <int> 0 <int>
    [ pango_layout_line_x_to_index drop ] 2keep
    [ *int ] bi@ + ;

: selection-rect ( dim layout selection -- rect )
    [ first-line ] [ [ start>> ] [ end>> ] bi ] bi*
    [ line-offset>x ] bi-curry@ bi
    [ drop nip 0 2array ] [ swap - swap second 2array ] 3bi <rect> ;

: fill-selection-background ( cr layout -- )
    dup string>> selection? [
        [ string>> color>> set-source-color ]
        [
            [ [ ink-rect>> dim>> ] [ layout>> ] [ string>> ] tri selection-rect ]
            [ ink-rect>> loc>> first ] bi rect-translate-x
            fill-rect
        ] 2bi
    ] [ 2drop ] if ;

: set-text-position ( cr loc -- )
    first2 cairo_move_to ;

: layout-metrics ( dim baseline -- metrics )
    metrics new
        swap >>ascent
        swap first2 [ >>width ] [ >>height ] bi*
        dup [ height>> ] [ ascent>> ] bi - >>descent ;

: text-position ( layout -- loc )
    [ logical-rect>> ] [ ink-rect>> ] bi [ loc>> ] bi@ v- ;

: draw-layout ( layout -- image )
    dup ink-rect>> dim>> [
        swap {
            [ layout>> pango_cairo_update_layout ]
            [ [ font>> ] [ ink-rect>> dim>> ] bi fill-background ]
            [ fill-selection-background ]
            [ text-position set-text-position ]
            [ font>> set-foreground ]
            [ layout>> pango_cairo_show_layout ]
        } 2cleave
    ] make-bitmap-image ;

: <layout> ( font string -- line )
    [
        layout new
            swap >>string
            swap >>font
            dup [ string>> ] [ font>> cache-font-description ] bi <PangoLayout> >>layout
            dup layout>> layout-extents [ >>ink-rect ] [ >>logical-rect ] bi*
            dup [ logical-rect>> dim>> ] [ layout>> layout-baseline ] bi layout-metrics >>metrics
            dup draw-layout >>image
    ] with-destructors ;

M: layout dispose* layout>> g_object_unref ;

SYMBOL: cached-layouts

: cached-layout ( font string -- layout )
    cached-layouts get [ <layout> ] 2cache ;

: cached-line ( font string -- line )
    cached-layout layout>> first-line ;

[ <cache-assoc> cached-layouts set-global ] "pango.layouts" add-init-hook