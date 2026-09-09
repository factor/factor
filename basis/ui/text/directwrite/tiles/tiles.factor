! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays assocs cache
destructors kernel locals math math.functions math.order math.rectangles
math.vectors namespaces opengl opengl.gl opengl.textures
opengl.textures.private ranges sequences ui.gadgets.worlds ui.render
ui.text.private windows.directwrite windows.directwrite.render ;
IN: ui.text.directwrite.tiles

CONSTANT: directwrite-tile-dim { 256 256 }

TUPLE: directwrite-tile < disposable texture vertices coords loc dim ;

M: directwrite-tile dispose* texture>> [ delete-texture ] when* ;

:: directwrite-modelview-clip ( rect matrix -- rect/f )
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

: directwrite-modelview ( -- matrix )
    gl3-mode? get-global [ current-modelview get-global ] [
        16 alien.c-types:float <c-array>
        [ GL_MODELVIEW_MATRIX swap glGetFloatv ] keep
        16 alien.c-types:float <c-array>
        [ GL_PROJECTION_MATRIX swap glGetFloatv ] keep
        swap mat4-multiply
    ] if ;

:: directwrite-viewport-clip ( rect viewport-dim -- rect' )
    rect rect-extent [ viewport-dim v/ { 2 -2 } v* { -1 1 } v+ ] bi@
    :> ( a b ) a b vmin a b vmax <extent-rect> ;

: directwrite-text-clip ( -- rect/f )
    clip get [
        ! Legacy UI puts its orthographic projection in MODELVIEW. Use the
        ! complete transform and convert the logical clip to normalized device
        ! coordinates, also supporting callers that use PROJECTION normally.
        gl3-mode? get-global [
            4 int <c-array> [ GL_VIEWPORT swap glGetIntegerv ] keep
            2 tail scale-dim directwrite-viewport-clip
        ] unless
        directwrite-modelview directwrite-modelview-clip
    ] [ f ] if* ;

:: directwrite-tile-offsets ( layout rect/f -- offsets )
    { 0 0 } layout size>> <rect> :> bounds
    rect/f [
        rect/f rect-extent [ [ gl-scale ] map layout origin>> v+ ] bi@
        <extent-rect> bounds rect-intersect
    ] [ bounds ] if :> visible
    visible dim>> [ 0 <= ] any? [ { } ] [
        visible rect-extent
        [ directwrite-tile-dim v/ [ floor >integer ] map ]
        [ directwrite-tile-dim v/ [ ceiling >integer ] map ] bi*
        [ [a..b) ] 2map first2 cartesian-product concat
        [ directwrite-tile-dim v* ] map
    ] if ;

:: <directwrite-tile> ( layout offset -- tile )
    layout size>> :> ext
    ext offset v- directwrite-tile-dim vmin :> dim
    ! Sample neighboring pixels for linear filtering, but draw only the
    ! interior so translucent backgrounds never overlap at tile boundaries.
    offset { 1 1 } v- { 0 0 } vmax :> raster-offset
    offset dim v+ { 1 1 } v+ ext vmin raster-offset v- :> raster-dim
    layout raster-offset raster-dim directwrite-layout>region-image :> image
    offset raster-offset v- raster-dim v/ :> uv-top
    dim raster-dim v/ :> uv-dim
    uv-top first :> u0
    u0 uv-dim first + :> u1
    1 uv-top second - :> v1
    v1 uv-dim second - :> v0
    offset layout origin>> v- scale-dim :> loc
    dim scale-dim :> logical-dim
    loc logical-dim make-textured-quad-vertices-flipped :> vertices
    6 <iota> [| i |
        i 4 * 2 + vertices [ uv-dim first * u0 + ] change-nth
        i 4 * 3 + vertices [ uv-dim second * v0 + ] change-nth
    ] each
    raster-dim raster-dim adjust-texture-dim v/ :> legacy-uv-scale
    u0 v1 2array u1 v1 2array u1 v0 2array u0 v0 2array
    4array [ legacy-uv-scale v* ] map concat alien.c-types:float >c-array :> coords
    [
        directwrite-tile new-disposable |dispose
        image gl3-mode? get-global [ make-texture-gl3 ] [ make-texture ] if >>texture
        vertices >>vertices coords >>coords loc >>loc logical-dim >>dim
    ] with-destructors ;

:: cached-directwrite-tile ( layout offset -- tile )
    layout offset world get world-text-handle [ <directwrite-tile> ] 2cache ;

:: draw-directwrite-tile ( tile -- )
    gl3-mode? get-global [
        tile vertices>> tile texture>> gl3-draw-texture-vertices
    ] [
        [
            GL_TEXTURE_2D tile texture>> glBindTexture
            init-texture tile coords>> gl-texture-coord-pointer
            tile loc>> tile dim>> gl-fill-rect
            GL_TEXTURE_2D 0 glBindTexture
        ] with-texturing
    ] if ;

:: draw-directwrite-tiles ( layout -- )
    layout directwrite-text-clip directwrite-tile-offsets
    [ layout swap cached-directwrite-tile draw-directwrite-tile ] each ;
