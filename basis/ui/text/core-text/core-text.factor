! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs cache combinators continuations
core-graphics.types core-text core-text.fonts destructors kernel
locals math math.functions math.order
math.rectangles math.vectors namespaces opengl opengl.gl
opengl.textures ranges sequences ui.gadgets.worlds ui.render ui.text
ui.text.private ;
IN: ui.text.core-text
SINGLETON: core-text-renderer

M: core-text-renderer string-dim
    [ " " string-dim { 0 1 } v* ]
    [ cached-line dim>> scale-dim ]
    if-empty ;

M: core-text-renderer flush-layout-cache
    cached-lines get-global purge-cache ;

M: core-text-renderer string>image
    cached-line [ line>image ] [ loc>> scale-dim ] bi ;

M:: core-text-renderer x>offset ( x font string -- n )
    string empty? [ 0 ] [
        font string cached-line :> line
        line line>> x gl-scale 0 <CGPoint> CTLineGetStringIndexForPosition
        line utf16>line-index
    ] if ;

M:: core-text-renderer offset>x ( n font string -- x )
    font string cached-line :> line
    line line>> n line line-index>utf16 f
    CTLineGetOffsetForStringIndex gl-unscale ;

M:: core-text-renderer selection-spans ( start end font string -- spans )
    font string cached-line start end line-selection-spans
    [ [ gl-unscale ] map ] map ;

M: core-text-renderer font-metrics
    cache-font-metrics clone scale-metrics ;

M: core-text-renderer line-metrics
    [ " " line-metrics 0 >>width ]
    [ cached-line metrics>> clone scale-metrics ]
    if-empty ;

<PRIVATE

CONSTANT: text-tile-dim { 512 256 }

TUPLE: text-tile < disposable texture vertices ;

M: text-tile dispose* texture>> [ delete-texture ] when* ;

! Convert the clip through the actual text transform, including translations
! made by editors/tables inside a gadget. Unusual transforms draw all tiles.
:: modelview-text-clip ( rect matrix -- rect/f )
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

: text-clip ( -- rect/f )
    clip get [ current-modelview get-global modelview-text-clip ] [ f ] if* ;

:: visible-tile-offsets ( line rect/f -- offsets )
    line prepare-render
    { 0 0 } line render-ext>> <rect> :> bounds
    rect/f [
        rect/f rect-extent [ [ gl-scale ] map line loc>> v- ] bi@
        <extent-rect> bounds rect-intersect
    ] [ bounds ] if :> visible
    visible dim>> [ 0 <= ] any? [ { } ] [
        visible rect-extent
        [ text-tile-dim v/ [ floor >integer ] map ]
        [ text-tile-dim v/ [ ceiling >integer ] map ] bi*
        [ [a..b) ] 2map first2 cartesian-product concat
        [ text-tile-dim v* ] map
    ] if ;

:: <text-tile> ( line offset -- tile )
    line render-ext>> :> ext
    ext offset v- text-tile-dim vmin :> dim
    ! Neighbor pixels are gutters for GL_LINEAR filtering. Only the interior
    ! is drawn, so adjacent tiles neither overlap nor introduce a seam.
    offset { 1 1 } v- { 0 0 } vmax :> raster-offset
    offset dim v+ { 1 1 } v+ ext vmin raster-offset v- :> raster-dim
    line raster-offset raster-dim render-region :> image
    offset raster-offset v- raster-dim v/ :> uv-loc
    dim raster-dim v/ :> uv-dim
    line loc>> offset v+ scale-dim dim scale-dim
    make-textured-quad-vertices :> vertices
    6 <iota> [| i |
        i 4 * 2 + vertices [ uv-dim first * uv-loc first + ] change-nth
        i 4 * 3 + vertices [ uv-dim second * uv-loc second + ] change-nth
    ] each
    [
        text-tile new-disposable |dispose
        image make-texture-gl3 >>texture
        vertices >>vertices
    ] with-destructors ;

:: cached-text-tile ( line offset -- tile )
    line offset world get world-text-handle [ <text-tile> ] 2cache ;

:: draw-line-tiles ( line -- )
    line text-clip visible-tile-offsets :> offsets
    GL_ONE GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    [
        offsets [
            line swap cached-text-tile
            [ vertices>> ] [ texture>> ] bi gl3-draw-texture-vertices
        ] each
    ] [ GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc ] finally ;

:: selection-outside-image ( line height -- bands )
    line prepare-render
    line loc>> second gl-unscale 0 height clamp :> top
    line loc>> second line render-ext>> second + gl-unscale
    0 height clamp :> bottom
    0 top 2array bottom height 2array 2array
    [ first2 < ] filter ;

:: draw-selected-line-tiles ( font selection height -- )
    font selection cached-line :> line
    line selection [ start>> ] [ end>> ] bi line-selection-spans
    [ [ gl-unscale ] map ] map :> spans
    ! The image already contains the selection background. Paint only the
    ! leading outside it; overlapping the image applies translucent colors
    ! twice when the font background is transparent.
    line height selection-outside-image [
        first2 :> ( top bottom )
        spans selection color>> top bottom top - draw-selection-rects
    ] each
    line draw-line-tiles ;

PRIVATE>

M: core-text-renderer draw-string*
    gl3-mode? get-global world get and [
        cached-line draw-line-tiles
    ] [ draw-string-default ] if ;

M: core-text-renderer draw-selected-string
    gl3-mode? get-global world get and
    [ draw-selected-line-tiles ] [ draw-selected-string-default ] if ;

core-text-renderer font-renderer set-global
