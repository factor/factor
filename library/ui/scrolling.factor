! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math matrices namespaces sequences
threads vectors styles ;

! A viewport can be scrolled.
TUPLE: viewport origin ;

! A scroller combines a viewport with two x and y sliders.
TUPLE: scroller viewport x y bottom? ;

: viewport-dim gadget-child pref-dim ;

: fix-scroll ( origin viewport -- origin )
    dup rect-dim swap viewport-dim v- vmax { 0 0 0 } vmin ;

C: viewport ( content -- viewport )
    <gadget> over set-delegate
    t over set-gadget-root?
    [ add-gadget ] keep
    { 0 0 0 } over set-viewport-origin ;

M: viewport pref-dim gadget-child pref-dim ;

M: viewport layout* ( viewport -- )
    dup viewport-origin over fix-scroll
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

: update-slider ( scroller slider -- )
    >r dup rect-dim
    over viewport-dim
    rot scroller-viewport viewport-origin vneg
    r> set-slider ;

: update-sliders ( scroller -- )
    dup
    dup scroller-x update-slider
    dup scroller-y update-slider ;

: scroll ( origin scroller -- )
    [
        scroller-viewport [ fix-scroll ] keep
        [ set-viewport-origin ] keep
        relayout
    ] keep update-sliders ;

: add-viewport 2dup set-scroller-viewport add-center ;

: add-x-slider 2dup set-scroller-x add-bottom ;

: add-y-slider 2dup set-scroller-y add-right ;

: scroll>bottom ( gadget -- )
    [ scroller? ] find-parent
    [ t over set-scroller-bottom? relayout ] when* ;

: scroll-up-line scroller-y -1 swap slide-by-line ;

: scroll-down-line scroller-y 1 swap slide-by-line ;

: scroller-actions ( scroller -- )
    dup [ scroll-up-line ] [ button-down 4 ] set-action
    [ scroll-down-line ] [ button-down 5 ] set-action ;

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
        dup scroller-viewport viewport-dim vneg over scroll
    ] when delegate layout* ;
