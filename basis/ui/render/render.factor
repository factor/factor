! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math.rectangles math.vectors namespaces kernel accessors
assocs combinators sequences sets opengl opengl.gl colors
colors.constants ui.gadgets ui.pens ;
FROM: namespaces => set ;
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
        [ [ 0 ] dip first2 0 1 -1 glOrtho ] tri
    ]
    [ clip set ] bi
    do-clip ;

SLOT: background-color

: init-gl ( world -- )
    GL_SMOOTH glShadeModel
    GL_SCISSOR_TEST glEnable
    GL_BLEND glEnable
    GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    GL_VERTEX_ARRAY glEnableClientState
    GL_PACK_ALIGNMENT 1 glPixelStorei
    GL_UNPACK_ALIGNMENT 1 glPixelStorei
    init-matrices
    [ init-clip ]
    [
        background-color>> >rgba-components glClearColor
        GL_COLOR_BUFFER_BIT glClear
    ] bi ;

GENERIC: draw-gadget* ( gadget -- )

M: gadget draw-gadget* drop ;

SYMBOL: origin

{ 0 0 } origin set-global

: visible-children ( gadget -- seq )
    [ clip get origin get vneg offset-rect ] dip children-on ;

: translate ( rect/point -- ) loc>> origin [ v+ ] change ;

GENERIC: draw-children ( gadget -- )

! For gadget selection
SYMBOL: selected-gadgets

SYMBOL: selection-background

GENERIC: selected-children ( gadget -- assoc/f selection-background )

M: gadget selected-children drop f f ;

! For text rendering
SYMBOL: background

SYMBOL: foreground

GENERIC: gadget-background ( gadget -- color )

M: gadget gadget-background dup interior>> pen-background ;

GENERIC: gadget-foreground ( gadget -- color )

M: gadget gadget-foreground dup interior>> pen-foreground ;

<PRIVATE

: draw-selection-background ( gadget -- )
    selection-background get background set
    selection-background get gl-color
    [ { 0 0 } ] dip dim>> gl-fill-rect ;

: draw-standard-background ( object -- )
    dup interior>> dup [ draw-interior ] [ 2drop ] if ;

: draw-background ( gadget -- )
    origin get [
        [
            dup selected-gadgets get in?
            [ draw-selection-background ]
            [ draw-standard-background ] if
        ] [ draw-gadget* ] bi
    ] with-translation ;

: draw-border ( object -- )
    dup boundary>> dup [
        origin get [ draw-boundary ] with-translation
    ] [ 2drop ] if ;

PRIVATE>

: (draw-gadget) ( gadget -- )
    dup loc>> origin get v+ origin [
        [ draw-background ] [ draw-children ] [ draw-border ] tri
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

M: gadget draw-children
    dup children>> [
        {
            [ visible-children ]
            [ selected-children ]
            [ gadget-background ]
            [ gadget-foreground ]
        } cleave [

            {
                [ [ selected-gadgets set ] when* ]
                [ [ selection-background set ] when* ]
                [ [ background set ] when* ]
                [ [ foreground set ] when* ]
            } spread
            [ draw-gadget ] each
        ] with-scope
    ] [ drop ] if ;

CONSTANT: selection-color T{ rgba f 0.8 0.8 1.0 1.0 }

CONSTANT: panel-background-color
    T{ rgba f
        0.7843137254901961
        0.7686274509803922
        0.7176470588235294
        1.0
    }

CONSTANT: focus-border-color COLOR: dark-gray
