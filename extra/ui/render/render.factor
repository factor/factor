! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays hashtables io kernel math namespaces opengl
opengl.gl opengl.glu sequences strings io.styles vectors
combinators math.vectors ui.gadgets colors ;
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
    rect-dim dup { 0 1 } v* viewport-translation set
    { 0 0 } over gl-viewport
    0 swap first2 0 gluOrtho2D
    clip set
    do-clip ;

: init-gl ( clip-rect rect -- )
    GL_SMOOTH glShadeModel
    GL_BLEND glEnable
    GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    init-matrices
    init-clip
    ! white gl-clear is broken w.r.t window resizing
    ! Linux/PPC Radeon 9200
    white gl-color
    clip get rect-extent gl-fill-rect ;

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
        dup dup gadget-interior draw-interior
        dup draw-gadget*
        dup visible-children [ draw-gadget ] each
        dup gadget-boundary draw-boundary
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
        { [ dup gadget-visible? not ] [ drop ] }
        { [ dup gadget-clipped? not ] [ (draw-gadget) ] }
        { [ t ] [ [ (draw-gadget) ] with-clipping ] }
    } cond ;

! Pen paint properties
M: f draw-interior 2drop ;
M: f draw-boundary 2drop ;

! Solid fill/border
TUPLE: solid color ;

C: <solid> solid

! Solid pen
: (solid)
    solid-color gl-color rect-dim >r origin get dup r> v+ ;

M: solid draw-interior (solid) gl-fill-rect ;

M: solid draw-boundary (solid) gl-rect ;

! Gradient pen
TUPLE: gradient colors ;

C: <gradient> gradient

M: gradient draw-interior
    origin get [
        over gadget-orientation
        swap gradient-colors
        rot rect-dim
        gl-gradient
    ] with-translation ;

! Polygon pen
TUPLE: polygon color points ;

C: <polygon> polygon

: draw-polygon ( polygon quot -- )
    origin get [
        >r dup polygon-color gl-color polygon-points r> call
    ] with-translation ; inline

M: polygon draw-boundary
    [ gl-poly ] draw-polygon drop ;

M: polygon draw-interior
    [ gl-fill-poly ] draw-polygon drop ;

: arrow-up    { { 3 0 } { 6 6 } { 0 6 } } ;
: arrow-right { { 0 0 } { 6 3 } { 0 6 } } ;
: arrow-down  { { 0 0 } { 6 0 } { 3 6 } } ;
: arrow-left  { { 0 3 } { 6 0 } { 6 6 } } ;
: close-box   { { 0 0 } { 6 0 } { 6 6 } { 0 6 } } ;

: <polygon-gadget> ( color points -- gadget )
    dup max-dim
    >r <polygon> <gadget> r> over set-rect-dim
    [ set-gadget-interior ] keep ;

! Checkbox and radio button pens
TUPLE: checkmark-paint color ;

C: <checkmark-paint> checkmark-paint

M: checkmark-paint draw-interior
    checkmark-paint-color gl-color
    origin get [
        rect-dim
        { 0 0 } over gl-line
        dup { 0 1 } v* swap { 1 0 } v* gl-line
    ] with-translation ;


TUPLE: radio-paint color ;

C: <radio-paint> radio-paint

M: radio-paint draw-interior
    radio-paint-color gl-color
    origin get { 4 4 } v+ swap rect-dim { 8 8 } v- 12 gl-fill-circle ;

M: radio-paint draw-boundary
    radio-paint-color gl-color
    origin get { 1 1 } v+ swap rect-dim { 2 2 } v- 12 gl-circle ;

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
        [ string-height ] curry* map sum
    ] if ;

: text-width ( open-font text -- n )
    dup string? [
        string-width
    ] [
        0 -rot [ string-width max ] curry* each
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
            ] curry* each
        ] with-translation
    ] if ;
