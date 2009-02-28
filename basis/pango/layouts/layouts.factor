! Copyright (C) 2008 Matthew Willis.
! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays sequences alien alien.c-types alien.destructors
alien.syntax math math.vectors destructors combinators colors fonts
accessors assocs namespaces kernel pango pango.fonts pango.cairo cairo
cairo.ffi glib unicode.data locals images cache init ;
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
    PANGO_SCALE /f ;

: set-layout-font ( str layout -- )
    swap pango_layout_set_font_description ;

: set-layout-text ( str layout -- )
    #! Replace nulls with something else since Pango uses null-terminated
    #! strings
    swap { { 0 CHAR: zero-width-no-break-space } } substitute
    -1 pango_layout_set_text ;

: <PangoLayout> ( text font -- layout )
    dummy-cairo pango_cairo_create_layout |g_object_unref
    [ set-layout-font ] keep
    [ set-layout-text ] keep ;

: set-foreground ( cr font -- )
    foreground>> set-source-color ;

: fill-background ( cr font dim -- )
    [ background>> set-source-color ]
    [ [ 0 0 ] dip first2 cairo_rectangle ] bi-curry*
    [ cairo_fill ]
    tri ;

:: fill-selection-background ( cr loc dim layout string -- )
    ;

: set-text-position ( cr loc -- )
    first2 cairo_move_to ;

: layout-metrics ( dim baseline -- metrics )
    metrics new
        swap >>ascent
        swap first2 [ >>width ] [ >>height ] bi*
        dup [ height>> ] [ ascent>> ] bi - >>descent ;

TUPLE: layout font layout metrics image loc dim disposed ;

:: <layout> ( font string -- line )
    [
        ! TODO: metrics and loc
        [let* | open-font [ font cache-font-description ]
                layout [ string open-font <PangoLayout> ]
                logical-rect [ layout layout-extents ] ink-rect [ ]
                baseline [ layout layout-baseline ]
                logical-loc [ logical-rect loc>> ]
                logical-dim [ logical-rect dim>> ]
                ink-loc [ ink-rect loc>> ]
                ink-dim [ ink-rect dim>> ]
                metrics [ logical-dim baseline layout-metrics ] |
            open-font layout metrics
            ink-dim [
                {
                    [ layout pango_cairo_update_layout ]
                    [ font ink-dim fill-background ]
                    [ font set-foreground ]
                    [ ink-loc ink-dim layout string fill-selection-background ]
                    [ logical-loc ink-loc v- set-text-position ]
                    [ layout pango_cairo_show_layout ]
                } cleave
            ] make-bitmap-image
            logical-loc ink-loc v-
            logical-dim
        ]
        f layout boa
    ] with-destructors ;

M: layout dispose* layout>> g_object_unref ;

SYMBOL: cached-layouts

: cached-layout ( font string -- layout )
    cached-layouts get [ <layout> ] 2cache ;

: cached-line ( font string -- line )
    cached-layout layout>> 0 pango_layout_get_line_readonly ;

[ <cache-assoc> cached-layouts set-global ] "pango.layouts" add-init-hook