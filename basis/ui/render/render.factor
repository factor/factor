! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays hashtables io kernel
math namespaces opengl opengl.gl opengl.glu sequences strings
io.styles vectors combinators math.vectors ui.gadgets colors
math.order math.geometry.rect locals ;
IN: ui.render

SYMBOL: clip

SYMBOL: viewport-translation

: flip-rect ( rect -- loc dim )
    rect-bounds [
        >r { 1 -1 } v* r> { 0 -1 } v* v+
        viewport-translation get v+
    ] keep ;

: do-clip ( -- ) clip get flip-rect gl-set-clip ;

: init-clip ( clip-rect rect -- )
    GL_SCISSOR_TEST glEnable
    [ rect-intersect ] keep
    dim>> dup { 0 1 } v* viewport-translation set
    { 0 0 } over gl-viewport
    0 swap first2 0 gluOrtho2D
    clip set
    do-clip ;

: init-gl ( clip-rect rect -- )
    GL_SMOOTH glShadeModel
    GL_BLEND glEnable
    GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    GL_VERTEX_ARRAY glEnableClientState
    init-matrices
    init-clip
    ! white gl-clear is broken w.r.t window resizing
    ! Linux/PPC Radeon 9200
    white gl-color
    clip get dim>> gl-fill-rect ;

GENERIC: draw-gadget* ( gadget -- )

M: gadget draw-gadget* drop ;

GENERIC: draw-interior ( gadget interior -- )

GENERIC: draw-boundary ( gadget boundary -- )

SYMBOL: origin

{ 0 0 } origin set-global

: visible-children ( gadget -- seq )
    clip get origin get vneg offset-rect swap children-on ;

: translate ( rect/point -- ) rect-loc origin [ v+ ] change ;

DEFER: draw-gadget

: (draw-gadget) ( gadget -- )
    [
        dup translate
        dup interior>> [
            origin get [ dupd draw-interior ] with-translation
        ] when*
        dup draw-gadget*
        dup visible-children [ draw-gadget ] each
        dup boundary>> [
            origin get [ dupd draw-boundary ] with-translation
        ] when*
        drop
    ] with-scope ;

: >absolute ( rect -- rect )
    origin get offset-rect ;

: change-clip ( gadget -- )
    >absolute clip [ rect-intersect ] change ;

: with-clipping ( gadget quot -- )
    clip get >r
    over change-clip do-clip call
    r> clip set do-clip ; inline

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
    [ dup rot v+ 2array ] with map
    concat concat >c-float-array ;

: gradient-colors ( colors -- seq )
    [ color>raw 4array dup 2array ] map concat concat >c-float-array ;

M: gradient recompute-pen ( gadget gradient -- )
    tuck
    [ [ orientation>> ] [ dim>> ] bi ] [ colors>> ] bi*
    [ gradient-vertices >>last-vertices ]
    [ gradient-colors >>last-colors ] bi
    drop ;

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
TUPLE: polygon color vertex-array count ;

: <polygon> ( color points -- polygon )
    [ concat >c-float-array ] [ length ] bi polygon boa ;

: draw-polygon ( polygon mode -- )
    swap
    [ color>> gl-color ]
    [ vertex-array>> gl-vertex-pointer ]
    [ 0 swap count>> glDrawArrays ]
    tri ;

M: polygon draw-boundary
    GL_LINE_LOOP draw-polygon drop ;

M: polygon draw-interior
    dup count>> 2 > GL_POLYGON GL_LINES ?
    draw-polygon drop ;

: arrow-up    { { 3 0 } { 6 6 } { 0 6 } } ;
: arrow-right { { 0 0 } { 6 3 } { 0 6 } } ;
: arrow-down  { { 0 0 } { 6 0 } { 3 6 } } ;
: arrow-left  { { 0 3 } { 6 0 } { 6 6 } } ;
: close-box   { { 0 0 } { 6 0 } { 6 6 } { 0 6 } } ;

: <polygon-gadget> ( color points -- gadget )
    dup max-dim
    >r <polygon> <gadget> r> >>dim
    swap >>interior ;

! Font rendering
SYMBOL: font-renderer

HOOK: open-font font-renderer ( font -- open-font )

HOOK: string-width font-renderer ( open-font string -- w )

HOOK: string-height font-renderer ( open-font string -- h )

HOOK: draw-string font-renderer ( font string loc -- )

HOOK: x>offset font-renderer ( x open-font string -- n )

HOOK: free-fonts font-renderer ( world -- )

: text-height ( open-font text -- n )
    dup string? [
        string-height
    ] [
        [ string-height ] with map sum
    ] if ;

: text-width ( open-font text -- n )
    dup string? [
        string-width
    ] [
        0 -rot [ string-width max ] with each
    ] if ;

: text-dim ( open-font text -- dim )
    [ text-width ] 2keep text-height 2array ;

: draw-text ( font text loc -- )
    over string? [
        draw-string
    ] [
        [
            [
                2dup { 0 0 } draw-string
                >r open-font r> string-height
                0.0 swap 0.0 glTranslated
            ] with each
        ] with-translation
    ] if ;
