! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings arrays assocs
cache cairo cairo.ffi classes.struct combinators destructors fonts fry
gobject.ffi init io.encodings.utf8 kernel math math.rectangles
math.vectors memoize namespaces pango.cairo.ffi pango.ffi sequences
ui.text ui.text.private ;
IN: ui.text.pango

: pango>float ( n -- x ) PANGO_SCALE /f ; inline
: float>pango ( x -- n ) PANGO_SCALE * >integer ; inline

MEMO:: (cache-font-description) ( name size bold? italic? -- description )
    [
        pango_font_description_new |pango_font_description_free {
            [ name utf8 string>alien pango_font_description_set_family ]
            [ size float>pango pango_font_description_set_size ]
            [ bold? PANGO_WEIGHT_BOLD PANGO_WEIGHT_NORMAL ? pango_font_description_set_weight ]
            [ italic? PANGO_STYLE_ITALIC PANGO_STYLE_NORMAL ? pango_font_description_set_style ]
            [ ]
        } cleave
    ] with-destructors ;

: cache-font-description ( font -- description )
    { [ name>> ] [ size>> ] [ bold?>> ] [ italic?>> ] } cleave
    (cache-font-description) ;

TUPLE: layout < disposable font string selection layout metrics ink-rect logical-rect image ;

SYMBOL: dpi

72 dpi set-global

: set-layout-font ( font layout -- )
    swap cache-font-description pango_layout_set_font_description ;

: set-layout-text ( str layout -- )
    swap utf8 string>alien -1 pango_layout_set_text ;

: PangoRectangle>rect ( PangoRectangle -- rect )
    [ [ x>> pango>float ] [ y>> pango>float ] bi 2array ]
    [ [ width>> pango>float ] [ height>> pango>float ] bi 2array ] bi
    <rect> ;

: layout-extents ( layout -- ink-rect logical-rect )
    PangoRectangle new
    PangoRectangle new
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
    ! n is an index into the UTF8 encoding of the text
    [ drop first-line ] [ swap string>> >utf8-index ] 2bi
    f { int } [ pango_layout_line_index_to_x ] with-out-parameters
    pango>float ;

: x>line-offset ( layout x -- n )
    ! n is an index into the UTF8 encoding of the text
    [
        [ first-line ] dip
        float>pango
        { int int }
        [ pango_layout_line_x_to_index drop ] with-out-parameters
        swap
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
    ! Replace nulls with something else since Pango uses null-terminated
    ! strings
    H{ { 0 CHAR: zero-width-no-break-space } } substitute ;

: unpack-selection ( layout string/selection -- layout )
    dup selection? [
        [ string>> escape-nulls >>string ] [ >>selection ] bi
    ] [ escape-nulls >>string ] if ; inline

: set-layout-resolution ( layout -- )
    pango_layout_get_context dpi get-global pango_cairo_context_set_resolution ;

: <PangoLayout> ( text font -- layout )
    dummy-cairo pango_cairo_create_layout |g_object_unref
    [ set-layout-resolution ] keep
    [ set-layout-font ] keep
    [ set-layout-text ] keep ;

: glyph-height ( font string -- y )
    swap <PangoLayout> &g_object_unref layout-extents drop dim>> second ;

MEMO: missing-font-metrics ( font -- metrics )
    ! Pango doesn't provide x-height and cap-height but Core Text does, so we
    ! simulate them on Pango.
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
    ] with-destructors ;

M: layout dispose* layout>> g_object_unref ;

SYMBOL: cached-layouts

: cached-layout ( font string -- layout )
    cached-layouts get-global [ <layout> ] 2cache ;

: cached-line ( font string -- line )
    cached-layout layout>> first-line ;

: layout>image ( layout -- image )
    dup image>> [ dup draw-layout >>image ] unless image>> ;

SINGLETON: pango-renderer

M: pango-renderer string-dim
    [ " " string-dim { 0 1 } v* ]
    [ cached-layout logical-rect>> dim>> v>integer ] if-empty ;

M: pango-renderer flush-layout-cache
    cached-layouts get-global purge-cache ;

M: pango-renderer string>image
    cached-layout [ layout>image ] [ text-position vneg ] bi ;

M: pango-renderer x>offset
    cached-layout swap x>line-offset ;

M: pango-renderer offset>x
    cached-layout swap line-offset>x ;

M: pango-renderer font-metrics
    " " cached-layout metrics>> clone f >>width ;

M: pango-renderer line-metrics
    [ " " line-metrics clone 0 >>width ]
    [ cached-layout metrics>> ]
    if-empty ;

STARTUP-HOOK: [
    \ (cache-font-description) reset-memoized
    <cache-assoc> cached-layouts set-global
]

pango-renderer font-renderer set-global
