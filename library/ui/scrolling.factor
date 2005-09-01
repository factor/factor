! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-scrolling
USING: gadgets gadgets-layouts generic kernel lists math
namespaces sequences threads vectors styles ;

! A viewport can be scrolled.
TUPLE: viewport ;

! A scroller combines a viewport with two x and y sliders.
TUPLE: scroller viewport x y bottom? ;

: scroller-origin ( scroller -- { x y 0 } )
    dup scroller-x slider-value
    swap scroller-y slider-value
    0 3vector ;

: find-scroller [ scroller? ] find-parent ;

: viewport-dim gadget-child pref-dim ;

C: viewport ( content -- viewport )
    <gadget> over set-delegate
    t over set-gadget-root?
    [ add-gadget ] keep ;

M: viewport pref-dim gadget-child pref-dim ;

M: viewport layout* ( viewport -- )
    dup find-scroller scroller-origin vneg
    swap gadget-child dup prefer
    set-rect-loc ;

M: viewport focusable-child* ( viewport -- gadget )
    gadget-child ;

: set-slider ( page max value slider -- )
    #! page/max/value are 3-vectors.
    [ [ slider-vector v. ] keep set-slider-value ] keep
    [ [ slider-vector v. ] keep set-slider-max ] keep
    [ [ slider-vector v. ] keep set-slider-page ] keep
    fix-slider ;

: update-slider ( scroller value slider -- )
    >r >r scroller-viewport dup rect-dim swap viewport-dim
    r> r> set-slider ;

: scroll ( scroller value -- )
    2dup
    over scroller-x update-slider
    over scroller-y update-slider ;

: add-viewport 2dup set-scroller-viewport add-center ;

: add-x-slider 2dup set-scroller-x add-bottom ;

: add-y-slider 2dup set-scroller-y add-right ;

: scroll>bottom ( gadget -- )
    find-scroller
    [ t over set-scroller-bottom? relayout ] when* ;

: scroll-up-line scroller-y -1 swap slide-by-line ;

: scroll-down-line scroller-y 1 swap slide-by-line ;

: scroller-actions ( scroller -- )
    dup [ scroll-up-line ] [ button-down 4 ] set-action
    dup [ scroll-down-line ] [ button-down 5 ] set-action
    [ scroller-viewport relayout ] [ slider-changed ] set-action ;

C: scroller ( gadget -- scroller )
    #! Wrap a scrolling pane around the gadget.
    <frame> over set-delegate
    [ >r <viewport> r> add-viewport ] keep
    <x-slider> over add-x-slider
    <y-slider> over add-y-slider
    dup scroller-actions ;

M: scroller focusable-child* ( scroller -- viewport )
    scroller-viewport ;

M: scroller layout* ( scroller -- )
    dup scroller-bottom? [
        f over set-scroller-bottom?
        dup dup scroller-viewport viewport-dim
        { 0 1 0 } v* scroll
    ] when delegate layout* ;
