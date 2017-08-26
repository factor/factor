USING: accessors arrays calendar circular colors
colors.constants fry kernel locals math math.order math.vectors
namespaces opengl processing.shapes sequences threads ui
ui.gadgets ui.gestures ui.render ;

IN: trails

! Example 33-15 from the Processing book

: mouse ( -- point )
    ! Return the mouse location relative to the current gadget
    hand-loc get hand-gadget get screen-loc v- ;

: point-list ( n -- seq ) { 0 0 } <array> <circular> ;

: percent->radius ( percent -- radius ) neg 1 + 25 * 5 max ;

: dot ( pos percent -- ) percent->radius draw-circle ;

TUPLE: trails-gadget < gadget paused points ;

:: iterate-system ( GADGET -- )
    ! Add a valid point if the mouse is in the gadget
    ! Otherwise, add an "invisible" point
    hand-gadget get GADGET = [ mouse ] [ { -10 -10 } ] if
    GADGET points>> circular-push ;

:: start-trails-thread ( GADGET -- )
    GADGET f >>paused drop
    [
        [
            GADGET paused>>
            [ f ]
            [ GADGET iterate-system GADGET relayout-1 1 milliseconds sleep t ]
            if
        ]
        loop
    ] "trails" spawn drop ;

M: trails-gadget ungraft* t >>paused drop ;

M: trails-gadget pref-dim* drop { 500 500 } ;

: each-percent ( seq quot -- )
    [ dup length ] dip '[ 1 + _ / @ ] each-index ; inline

M:: trails-gadget draw-gadget* ( GADGET -- )
    T{ rgba f 1 1 1 0.4 } \ fill-color set   ! White, with some transparency
    T{ rgba f 0 0 0 0   } \ stroke-color set ! no stroke
    color: black gl-clear
    GADGET points>> [ dot ] each-percent ;

: <trails-gadget> ( -- trails-gadget )
    trails-gadget new
        300 point-list >>points
        t >>clipped?
    dup start-trails-thread ;

MAIN-WINDOW: trails-window
    { { title "Trails" } }
    <trails-gadget> >>gadgets ;
