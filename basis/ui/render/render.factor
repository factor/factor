! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays hashtables io io.pathnames
kernel math namespaces opengl opengl.gl opengl.glu sequences strings
vectors combinators math.vectors ui.gadgets ui.images colors fry
colors.constants math.order math.rectangles locals
specialized-arrays.float ;
IN: ui.render

SYMBOL: clip

SYMBOL: viewport-translation

: flip-rect ( rect -- loc dim )
    rect-bounds [
        [ { 1 -1 } v* ] dip { 0 -1 } v* v+
        viewport-translation get v+
    ] keep ;

: do-clip ( -- ) clip get flip-rect gl-set-clip ;

: init-clip ( clip-rect -- )
    [
        dim>>
        [ { 0 1 } v* viewport-translation set ]
        [ [ { 0 0 } ] dip gl-viewport ]
        [ [ 0 ] dip first2 0 gluOrtho2D ] tri
    ]
    [ clip set ] bi
    do-clip ;

: init-gl ( clip-rect -- )
    GL_SMOOTH glShadeModel
    GL_SCISSOR_TEST glEnable
    GL_BLEND glEnable
    GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    GL_VERTEX_ARRAY glEnableClientState
    init-matrices
    init-clip
    ! white gl-clear is broken w.r.t window resizing
    ! Linux/PPC Radeon 9200
    COLOR: white gl-color
    clip get dim>> gl-fill-rect ;

GENERIC: draw-gadget* ( gadget -- )

M: gadget draw-gadget* drop ;

GENERIC: draw-interior ( gadget interior -- )

GENERIC: draw-boundary ( gadget boundary -- )

GENERIC: pen-pref-dim ( gadget pen -- dim )

M: object pen-pref-dim 2drop { 0 0 } ;

SYMBOL: origin

{ 0 0 } origin set-global

: visible-children ( gadget -- seq )
    [ clip get origin get vneg offset-rect ] dip children-on ;

: translate ( rect/point -- ) loc>> origin [ v+ ] change ;

DEFER: draw-gadget

: (draw-gadget) ( gadget -- )
    dup loc>> origin get v+ origin [
        [
            origin get [
                [ dup interior>> dup [ draw-interior ] [ 2drop ] if ]
                [ draw-gadget* ]
                bi
            ] with-translation
        ]
        [ visible-children [ draw-gadget ] each ]
        [
            dup boundary>> dup [
                origin get [ draw-boundary ] with-translation
            ] [ 2drop ] if
        ] tri
    ] with-variable ;

: >absolute ( rect -- rect )
    origin get offset-rect ;

: change-clip ( gadget -- )
    >absolute clip [ rect-intersect ] change ;

: with-clipping ( gadget quot -- )
    clip get [ over change-clip do-clip call ] dip clip set do-clip ; inline

: draw-gadget ( gadget -- )
    {
        { [ dup visible?>> not ] [ drop ] }
        { [ dup clipped?>> not ] [ (draw-gadget) ] }
        [ [ (draw-gadget) ] with-clipping ]
    } cond ;

! A pen that caches vertex arrays, etc
TUPLE: caching-pen last-dim ;

GENERIC: recompute-pen ( gadget pen -- )

: compute-pen ( gadget pen -- )
    2dup [ dim>> ] [ last-dim>> ] bi* = [
        2drop
    ] [
        [ swap dim>> >>last-dim drop ] [ recompute-pen ] 2bi
    ] if ;

! Solid fill/border
TUPLE: solid < caching-pen color interior-vertices boundary-vertices ;

: <solid> ( color -- solid ) solid new swap >>color ;

M: solid recompute-pen
    swap dim>>
    [ (fill-rect-vertices) >>interior-vertices ]
    [ (rect-vertices) >>boundary-vertices ]
    bi drop ;

<PRIVATE

! Solid pen
: (solid) ( gadget pen -- )
    [ compute-pen ] [ color>> gl-color ] bi ;

PRIVATE>

M: solid draw-interior
    [ (solid) ] [ interior-vertices>> gl-vertex-pointer ] bi
    (gl-fill-rect) ;

M: solid draw-boundary
    [ (solid) ] [ boundary-vertices>> gl-vertex-pointer ] bi
    (gl-rect) ;

! Gradient pen
TUPLE: gradient < caching-pen colors last-vertices last-colors ;

: <gradient> ( colors -- gradient ) gradient new swap >>colors ;

<PRIVATE

:: gradient-vertices ( direction dim colors -- seq )
    direction dim v* dim over v- swap
    colors length dup 1- v/n [ v*n ] with map
    swap [ over v+ 2array ] curry map
    concat concat >float-array ;

: gradient-colors ( colors -- seq )
    [ >rgba-components 4array dup 2array ] map concat concat
    >float-array ;

M: gradient recompute-pen ( gadget gradient -- )
    [ nip ] [ [ [ orientation>> ] [ dim>> ] bi ] [ colors>> ] bi* ] 2bi
    [ gradient-vertices >>last-vertices ]
    [ gradient-colors >>last-colors ]
    bi drop ;

: draw-gradient ( colors -- )
    GL_COLOR_ARRAY [
        [ GL_QUAD_STRIP 0 ] dip length 2 * glDrawArrays
    ] do-enabled-client-state ;

PRIVATE>

M: gradient draw-interior
    {
        [ compute-pen ]
        [ last-vertices>> gl-vertex-pointer ]
        [ last-colors>> gl-color-pointer ]
        [ colors>> draw-gradient ]
    } cleave ;

! Polygon pen
TUPLE: polygon color
interior-vertices
interior-count
boundary-vertices
boundary-count ;

: <polygon> ( color points -- polygon )
    dup close-path [ [ concat >float-array ] [ length ] bi ] bi@
    polygon boa ;

M: polygon draw-boundary
    nip
    [ color>> gl-color ]
    [ boundary-vertices>> gl-vertex-pointer ]
    [ [ GL_LINE_STRIP 0 ] dip boundary-count>> glDrawArrays ]
    tri ;

M: polygon draw-interior
    nip
    [ color>> gl-color ]
    [ interior-vertices>> gl-vertex-pointer ]
    [ [ GL_POLYGON 0 ] dip interior-count>> glDrawArrays ]
    tri ;

: theme-image ( name -- image-name )
    "resource:basis/ui/gadgets/theme/" prepend-path ".tiff" append <image-name> ;

! Image pen
TUPLE: image-pen image fill? ;

: <image-pen> ( image -- pen ) f image-pen boa ;

M: image-pen draw-interior
    [ dim>> ] [ [ image>> ] [ fill?>> ] bi ] bi*
    [ draw-scaled-image ] [
        [ image-dim [ - 2/ ] 2map ] keep
        '[ _ draw-image ] with-translation
    ] if ;

M: image-pen pen-pref-dim nip image>> image-dim ;

! Tile pen
TUPLE: tile-pen left center right ;

: <tile-pen> ( left center right -- pen )
    tile-pen boa ;

: >tile-pen< ( pen -- left center right )
    [ left>> ] [ center>> ] [ right>> ] tri ; inline

M: tile-pen pen-pref-dim
    swap [
        >tile-pen< [ image-dim ] tri@
        [ vmax vmax ] [ v+ v+ ] 3bi
    ] dip orientation>> set-axis ;

: compute-tile-xs ( gadget pen -- x1 x2 x3 )
    [ 2drop { 0 0 } ]
    [ nip left>> image-dim ]
    [ [ dim>> ] [ right>> image-dim ] bi* v- ]
    2tri ;

: compute-tile-widths ( gadget pen -- w1 w2 w3 )
    [ nip left>> image-dim ]
    [ [ dim>> ] [ [ left>> ] [ right>> ] bi [ image-dim ] bi@ ] bi* v+ v- ]
    [ nip right>> image-dim ]
    2tri ;

: render-tile ( tile x width gadget -- )
    [ orientation>> '[ _ v* ] dip ] keep
   '[
       _ _ [ dim>> swap ] [ orientation>> ] bi set-axis
       swap draw-scaled-image
   ] with-translation ;

M: tile-pen draw-interior ( gadget pen -- )
    {
        [ nip >tile-pen< ]
        [ compute-tile-xs ]
        [ compute-tile-widths ]
        [ drop ]
    } 2cleave
    [ render-tile ] curry tri-curry@ tri-curry* tri* ;