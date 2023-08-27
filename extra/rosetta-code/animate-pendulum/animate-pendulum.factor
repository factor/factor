! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays calendar colors kernel math
math.constants math.functions math.rectangles math.vectors
opengl sequences system timers ui ui.gadgets ui.render ;

IN: rosetta-code.animate-pendulum

! https://rosettacode.org/wiki/Animate_a_pendulum

! One good way of making an animation is by simulating a
! physical system and illustrating the variables in that system
! using a dynamically changing graphical display. The classic such
! physical system is a simple gravity pendulum.

! For this task, create a simple physical model of a pendulum
! and animate it.

CONSTANT: g 9.81
CONSTANT: l 20
CONSTANT: theta0 0.5

: current-time ( -- time ) nano-count -9 10^ * ;

: T0 ( -- T0 ) 2 pi l g / sqrt * * ;
: omega0 ( -- omega0 ) 2 pi * T0 / ;
: theta ( -- theta ) current-time omega0 * cos theta0 * ;

: relative-xy ( theta l -- xy )
    [ [ sin ] [ cos ] bi ]
    [ [ * ] curry ] bi* bi@ 2array ;
: theta-to-xy ( origin theta l -- xy ) relative-xy v+ ;

TUPLE: pendulum-gadget < gadget alarm ;

: O ( gadget -- origin ) rect-bounds [ drop ] [ first 2 / ] bi* 0 2array ;
: window-l ( gadget -- l ) rect-bounds [ drop ] [ second ] bi* ;
: gadget-xy ( gadget -- xy ) [ O ] [ drop theta ] [ window-l ] tri theta-to-xy ;

M: pendulum-gadget draw-gadget*
    COLOR: black gl-color
    [ O ] [ gadget-xy ] bi gl-line ;

M: pendulum-gadget graft* ( gadget -- )
    [ call-next-method ]
    [
        dup [ relayout-1 ] curry
        20 milliseconds every >>alarm drop
    ] bi ;

M: pendulum-gadget ungraft*
    [ alarm>> stop-timer ] [ call-next-method ] bi ;

: <pendulum-gadget> ( -- gadget )
    pendulum-gadget new
    { 500 500 } >>pref-dim ;

MAIN-WINDOW: pendulum-main
    { { title "pendulum" } }
    <pendulum-gadget> >>gadgets ;
