! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math.rectangles math.vectors namespaces kernel accessors
combinators sequences opengl opengl.gl opengl.glu colors
colors.constants ui.gadgets ui.pens ;
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
    { 0 0 } clip get dim>> gl-fill-rect ;

GENERIC: draw-gadget* ( gadget -- )

M: gadget draw-gadget* drop ;

SYMBOL: origin

{ 0 0 } origin set-global

: visible-children ( gadget -- seq )
    [ clip get origin get vneg offset-rect ] dip children-on ;

: translate ( rect/point -- ) loc>> origin [ v+ ] change ;

GENERIC: draw-children ( gadget -- )

: (draw-gadget) ( gadget -- )
    dup loc>> origin get v+ origin [
        [
            origin get [
                [ dup interior>> dup [ draw-interior ] [ 2drop ] if ]
                [ draw-gadget* ]
                bi
            ] with-translation
        ]
        [ draw-children ]
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

! For text rendering
SYMBOL: background

SYMBOL: foreground

GENERIC: gadget-background ( gadget -- color )

M: gadget gadget-background dup interior>> pen-background ;

GENERIC: gadget-foreground ( gadget -- color )

M: gadget gadget-foreground dup interior>> pen-foreground ;

M: gadget draw-children
    [ visible-children ]
    [ gadget-background ]
    [ gadget-foreground ] tri [
        [ foreground set ] when*
        [ background set ] when*
        [ draw-gadget ] each
    ] with-scope ;

CONSTANT: selection-color T{ rgba f 0.8 0.8 1.0 1.0 }

CONSTANT: panel-background-color
    T{ rgba f
        0.7843137254901961
        0.7686274509803922
        0.7176470588235294
        1.0
    }

CONSTANT: focus-border-color COLOR: dark-gray
