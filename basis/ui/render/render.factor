! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors colors combinators kernel math.rectangles
math.vectors namespaces opengl opengl.capabilities opengl.gl
opengl.textures sequences sets ui.gadgets ui.pens ;
IN: ui.render

! GL3 mode flag - set to t for GL3 core profile contexts
SYMBOL: gl3-mode?

SYMBOL: clip

SYMBOL: viewport-translation

: flip-rect ( rect -- loc dim )
    rect-bounds [
        [ { 1 -1 } v* ] dip { 0 -1 } v* v+
        viewport-translation get v+
    ] keep ;

: do-clip ( -- ) clip get flip-rect gl-set-clip ;

: init-clip ( gadget -- )
    [
        dim>>
        [ { 0 1 } v* viewport-translation namespaces:set ]
        [ [ { 0 0 } ] dip gl-viewport ]
        [ [ 0 ] dip first2 0 1 -1 glOrtho ] tri
    ]
    [ clip namespaces:set ] bi
    do-clip ;

SLOT: background-color

! --- GL3 Mode Hooks ---
SYMBOL: gl-init-hook
SYMBOL: gl-draw-init-hook

: gl-init-legacy ( -- )
    GL_SMOOTH glShadeModel
    GL_BLEND glEnable
    GL_VERTEX_ARRAY glEnableClientState
    GL_PACK_ALIGNMENT 1 glPixelStorei
    GL_UNPACK_ALIGNMENT 1 glPixelStorei ;

: gl-init ( -- )
    gl-init-hook get-global [ call( -- ) ] [ gl-init-legacy ] if* ;

: gl-draw-init-legacy ( world -- )
    GL_SCISSOR_TEST glEnable
    GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    init-matrices
    [ init-clip ] [ background-color>> gl-clear ] bi ;

: gl-draw-init ( world -- )
    gl-draw-init-hook get-global
    [ call( world -- ) ] [ gl-draw-init-legacy ] if* ;

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
    selection-background get background namespaces:set
    selection-background get gl-color
    [ { 0 0 } ] dip dim>> gl-fill-rect ;

: draw-standard-background ( object -- )
    dup interior>> [ draw-interior ] [ drop ] if* ;

: draw-background ( gadget -- )
    origin get swap '[
        _ [
            dup selected-gadgets get in?
            [ draw-selection-background ]
            [ draw-standard-background ] if
        ] [ draw-gadget* ] bi
    ] with-translation ;

: draw-border ( object -- )
    dup boundary>> [
        origin get -rot '[ _ _ draw-boundary ] with-translation
    ] [ drop ] if* ;

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
    clip get [ over change-clip do-clip call ] dip
    clip namespaces:set do-clip ; inline

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
                [ [ selected-gadgets namespaces:set ] when* ]
                [ [ selection-background namespaces:set ] when* ]
                [ [ background namespaces:set ] when* ]
                [ [ foreground namespaces:set ] when* ]
            } spread
            [ draw-gadget ] each
        ] with-scope
    ] [ drop ] if ;
