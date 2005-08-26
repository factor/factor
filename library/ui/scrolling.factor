! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math matrices namespaces sequences
threads vectors styles ;

! A viewport can be scrolled.
TUPLE: viewport origin bottom? ;

! A scroller combines a viewport with two x and y sliders.
TUPLE: scroller viewport x y ;

: viewport-dim gadget-child pref-dim ;

: fix-scroll ( origin viewport -- origin )
    dup rect-dim swap viewport-dim v- vmax { 0 0 0 } vmin ;

C: viewport ( content -- viewport )
    <gadget> over set-delegate
    t over set-gadget-root?
    [ add-gadget ] keep
    { 0 0 0 } over set-viewport-origin ;

M: viewport pref-dim gadget-child pref-dim ;

: viewport-origin* ( viewport -- point )
    dup viewport-bottom? [
        f over set-viewport-bottom?
        dup viewport-dim { 0 -1 0 } v*
        [ swap set-viewport-origin ] keep
    ] [
        viewport-origin
    ] ifte ;

M: viewport layout* ( viewport -- )
    dup gadget-child dup prefer
    >r dup viewport-origin* swap fix-scroll r>
    set-rect-loc ;

M: viewport focusable-child* ( viewport -- gadget )
    gadget-child ;

: update-slider ( slider scroller -- )
    dup rect-dim pick slider-vector v. pick set-slider-page
    dup viewport-dim over rect-dim vmax pick slider-vector v. pick set-slider-max
    slider-viewport dup viewport-origin over fix-scroll vneg pick slider-vector v. pick set-slider-value
    drop slider-elevator relayout ;

: update-sliders ( scroller -- )
    dup scroller-x over update-slider
    dup scroller-y swap update-slider ;

: scroll ( origin scroller -- )
    [
        scroller-viewport [ fix-scroll ] keep
        [ set-viewport-origin ] keep
    ] keep relayout ;

: add-viewport 2dup set-scroller-viewport add-center ;

: add-x-slider 2dup set-scroller-x add-bottom ;

: add-y-slider 2dup set-scroller-y add-right ;

: (scroll>bottom) ( scroller -- )
    t swap scroller-viewport set-viewport-bottom? ;

: scroll>bottom ( gadget -- )
    [ scroll>bottom ] swap handle-gesture drop ;

: scroll-by ( scroller amount -- )
    over scroller-viewport viewport-origin v+ swap scroll ;

: scroll-up-line { 0 32 0 } scroll-by ;

: scroll-down-line { 0 -32 0 } scroll-by ;

: scroller-actions ( scroller -- )
    dup [ (scroll>bottom) ] [ scroll>bottom ] set-action
    dup [ scroll-up-line ] [ button-down 4 ] set-action
    [ scroll-down-line ] [ button-down 5 ] set-action ;

C: scroller ( gadget -- scroller )
    #! Wrap a scrolling pane around the gadget.
    <frame> over set-delegate
    [ >r <viewport> r> add-viewport ] keep
    <x-slider> over add-x-slider
    <y-slider> over add-y-slider
    dup scroller-actions ;

M: scroller focusable-child* ( viewport -- gadget )
    scroller-viewport ;

M: scroller layout* ( scroller -- )
    dup update-sliders delegate layout* ;
