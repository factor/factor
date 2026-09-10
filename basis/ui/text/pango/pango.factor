! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings arrays
assocs cache cairo cairo.ffi classes.struct combinators
continuations destructors fonts fry gobject.ffi init io.encodings.utf8 kernel locals
math math.functions math.order math.rectangles math.vectors memoize namespaces
opengl opengl.gl opengl.textures pango.cairo.ffi pango.ffi ranges sequences
ui.gadgets.worlds ui.render ui.text ui.text.index-maps
ui.text.pango.indexed ui.text.private ;
FROM: destructors.private => register-disposable ;
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
    {
        [ name>> ]
        [ size>> gl-scale-factor get-global [ * ] when* ]
        [ bold?>> ]
        [ italic?>> ]
    } cleave (cache-font-description) ;

TUPLE: layout < disposable font string selection layout metrics ink-rect logical-rect image glyph-index index-map ;

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

:: layout-index-map ( layout -- map )
    layout index-map>> [ ] [
        layout string>> <utf8-index-map> dup layout index-map<<
    ] if* ;

:: line-offset>x ( layout n -- x )
    layout glyph-index>> [ n swap indexed-offset>x ] [
        layout first-line n layout layout-index-map codepoint>native
        f { int } [ pango_layout_line_index_to_x ] with-out-parameters pango>float
    ] if* ;

:: x>line-offset ( layout x -- n )
    layout glyph-index>> [
        x 0 layout metrics>> width>> clamp swap indexed-x>offset
    ] [
        layout first-line x float>pango
        { int int } [ pango_layout_line_x_to_index drop ] with-out-parameters
        swap layout layout-index-map native>codepoint +
    ] if* ;

: selection-start/end ( selection -- start end )
    selection>> [ start>> ] [ end>> ] bi [ min ] [ max ] 2bi ;

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

! Bound explicit whole-line image previews. On-screen text uses visible
! tiles below and is never truncated to this surface-size limit.
CONSTANT: max-layout-dim 16384

: clamp-layout-dim ( dim -- dim' )
    [ max-layout-dim min ] map ;

:: fill-selection-region ( cr layout offset dim -- )
    layout selection>> [
        cr layout selection>> color>> set-source-color
        layout selection-rect layout ink-rect>> loc>> first rect-translate-x
        offset dim <rect> rect-intersect
        [ offset v- ] change-loc cr swap fill-rect
    ] when ;

! Rasterize a bounded region of the original shaped layout. Do not split
! the string: shaping, fallback and bidi ordering must span tile boundaries.
:: draw-layout-region ( layout offset dim -- image )
    dim [| cr |
        ! Fill in tile coordinates: a 70-million-pixel Cairo rectangle can
        ! overflow Cairo's fixed-point geometry even on a tiny surface.
        cr layout font>> dim fill-background
        cr layout offset dim fill-selection-region
        cr offset vneg first2 cairo_translate
        cr layout font>> set-foreground
        layout glyph-index>> [| index |
            cr layout text-position first2 cairo_translate
            cr index offset first layout text-position first - dim first draw-indexed-region
        ] [
            cr layout text-position set-text-position
            cr layout layout>> pango_cairo_show_layout
        ] if*
        cr check-cairo
    ] make-bitmap-image ;

: layout-image-dim ( layout -- dim )
    ink-rect>> dim>> [ ceiling >integer ] map ;

: draw-layout ( layout -- image )
    dup layout-image-dim clamp-layout-dim { 0 0 } swap draw-layout-region ;

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

: <plain-layout> ( font string -- line )
    [
        layout new-disposable
            swap unpack-selection
            swap >>font
            dup [ string>> ] [ font>> ] bi <PangoLayout> >>layout
            dup layout>> layout-extents [ >>ink-rect ] [ >>logical-rect ] bi*
            dup layout-metrics >>metrics
            ! Keep wide positions in Factor and index the existing glyphs.
            ! Printable ASCII has monotonic horizontal advances; other text
            ! retains native Pango hit testing and drawing semantics.
            dup string>> dup length 4096 > [
                [ dup 32 >= swap 126 <= and ] all?
            ] [ drop f ] if [
                dup [ layout>> ] [ metrics>> ascent>> ] bi <glyph-index> >>glyph-index
                dup glyph-index>> ink>> >>ink-rect
                dup [ glyph-index>> width>> ] [ logical-rect>> dim>> second ] bi 2array
                over logical-rect>> swap >>dim drop
                dup [ glyph-index>> width>> ] [ metrics>> ] bi swap >>width drop
            ] when
    ] with-destructors ;

DEFER: cached-layout

:: <layout> ( font text -- layout )
    text selection? [
        ! Selection changes must not reshape a multi-million-character row.
        font text string>> cached-layout dup layout-index-map drop clone
        dup layout>> g_object_ref drop
        dup register-disposable
        text >>selection f >>image
    ] [ font text <plain-layout> ] if ;

M: layout dispose* layout>> g_object_unref ;

SYMBOL: cached-layouts

: cached-layout ( font string -- layout )
    gl-scale-factor get-global 3array
    cached-layouts get-global [ first2 <layout> ] cache ;

: cached-line ( font string -- line )
    cached-layout layout>> first-line ;

: layout>image ( layout -- image )
    dup image>> [ dup draw-layout >>image ] unless image>> ;

SINGLETON: pango-renderer

M: pango-renderer string-dim
    [ " " string-dim { 0 1 } v* ]
    [ cached-layout logical-rect>> dim>> scale-dim v>integer ] if-empty ;

M: pango-renderer flush-layout-cache
    cached-layouts get-global purge-cache ;

M: pango-renderer string>image
    cached-layout [ layout>image ] [ text-position scale-dim vneg ] bi ;

M: pango-renderer x>offset
    [ gl-scale ] 2dip cached-layout swap x>line-offset ;

M: pango-renderer offset>x
    cached-layout swap line-offset>x gl-unscale ;

M: pango-renderer font-metrics
    " " cached-layout metrics>> clone scale-metrics f >>width ;

M: pango-renderer line-metrics
    [ " " line-metrics 0 >>width ]
    [ cached-layout metrics>> clone scale-metrics ]
    if-empty ;

<PRIVATE

CONSTANT: pango-tile-dim { 512 256 }

TUPLE: pango-tile < disposable texture vao vbo ;

M: pango-tile dispose*
    [ vao>> [ 1 swap uint <ref> glDeleteVertexArrays ] when* ]
    [ vbo>> [ 1 swap uint <ref> glDeleteBuffers ] when* ]
    [ texture>> [ delete-texture ] when* ] tri ;

! Invert the actual text transform, including scrolling within an editor.
! Unusual transforms conservatively draw every tile.
:: pango-modelview-clip ( rect matrix -- rect/f )
    matrix first :> sx
    5 matrix nth :> sy
    sx zero? sy zero? or
    1 matrix nth zero? 4 matrix nth zero? and not or
    3 matrix nth zero? 7 matrix nth zero? and
    15 matrix nth 1 number= and not or [ f ] [
        12 matrix nth 13 matrix nth 2array :> translation
        sx sy 2array :> scale
        rect rect-extent [ translation v- scale v/ ] bi@ :> ( a b )
        a b vmin a b vmax <extent-rect>
    ] if ;

: pango-text-clip ( -- rect/f )
    clip get [ current-modelview get-global pango-modelview-clip ] [ f ] if* ;

:: pango-tile-offsets ( layout rect/f -- offsets )
    { 0 0 } layout layout-image-dim <rect> :> bounds
    rect/f [
        rect/f rect-extent [ [ gl-scale ] map layout text-position v+ ] bi@
        <extent-rect> bounds rect-intersect
    ] [ bounds ] if :> visible
    visible dim>> [ 0 <= ] any? [ { } ] [
        visible rect-extent
        [ pango-tile-dim v/ [ floor >integer ] map ]
        [ pango-tile-dim v/ [ ceiling >integer ] map ] bi*
        [ [a..b) ] 2map first2 cartesian-product concat
        [ pango-tile-dim v* ] map
    ] if ;

:: <pango-tile> ( layout offset -- tile )
    layout layout-image-dim :> ext
    ext offset v- pango-tile-dim vmin :> dim
    ! A pixel gutter supports linear filtering without overlapping the drawn
    ! interiors, which would apply translucent backgrounds twice.
    offset { 1 1 } v- { 0 0 } vmax :> raster-offset
    offset dim v+ { 1 1 } v+ ext vmin raster-offset v- :> raster-dim
    layout raster-offset raster-dim draw-layout-region :> image
    offset raster-offset v- raster-dim v/ :> uv-loc
    dim raster-dim v/ :> uv-dim
    offset layout text-position v- scale-dim dim scale-dim
    make-textured-quad-vertices :> vertices
    6 <iota> [| i |
        i 4 * 2 + vertices [ uv-dim first * uv-loc first + ] change-nth
        i 4 * 3 + vertices [ uv-dim second * uv-loc second + ] change-nth
    ] each
    [
        pango-tile new-disposable |dispose
        image make-texture-gl3 >>texture
        create-gl3-vao >>vao
        create-gl3-vbo >>vbo
        dup vao>> glBindVertexArray
        dup vbo>> GL_ARRAY_BUFFER swap glBindBuffer
        GL_ARRAY_BUFFER vertices [ byte-length ] keep GL_STATIC_DRAW glBufferData
        setup-texture-vertex-attributes
    ] with-destructors ;

: cached-pango-tile ( layout offset -- tile )
    world get world-text-handle [ <pango-tile> ] 2cache ;

:: draw-pango-tiles ( layout -- )
    layout pango-text-clip pango-tile-offsets :> offsets
    offsets empty? [
        ! Cairo's ARGB32 pixels contain premultiplied alpha.
        GL_ONE GL_ONE_MINUS_SRC_ALPHA glBlendFunc
        [
            [ offsets [
                layout swap cached-pango-tile
                [ vao>> ] [ texture>> ] bi gl3-draw-cached-texture
            ] each ] with-gl3-cached-textures
        ] [ GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc ] finally
    ] unless ;

PRIVATE>

M: pango-renderer draw-string*
    gl3-mode? get-global world get and [
        2dup cached-layout layout-image-dim [ 512 > ] any?
        [ cached-layout draw-pango-tiles ] [ draw-string-default ] if
    ] [ draw-string-default ] if ;

STARTUP-HOOK: [
    \ (cache-font-description) reset-memoized
    \ missing-font-metrics reset-memoized
    <cache-assoc> cached-layouts set-global
]

pango-renderer font-renderer set-global
