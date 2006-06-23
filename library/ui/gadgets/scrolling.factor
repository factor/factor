! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-scrolling
USING: arrays gadgets gadgets-frames gadgets-theme
gadgets-viewports generic kernel math namespaces sequences ;

! A scroller combines a viewport with two x and y sliders.
! The follows slot is set by scroll-to.
TUPLE: scroller viewport x y follows ;

: scroller-origin ( scroller -- { x y 0 } )
    dup scroller-x slider-value
    swap scroller-y slider-value
    2array ;

: find-scroller [ scroller? ] find-parent ;

: scroll-to ( gadget -- )
    #! Scroll the scroller that contains this gadget, if any, so
    #! that the gadget becomes visible.
    dup find-scroller dup
    [ [ set-scroller-follows ] keep relayout ] [ 2drop ] if ;

: scroll-up-line scroller-y -1 swap slide-by-line ;

: scroll-down-line scroller-y 1 swap slide-by-line ;

M: scroller gadget-gestures
    drop H{
        { T{ wheel-up } [ scroll-up-line ] }
        { T{ wheel-down } [ scroll-down-line ] }
        { T{ slider-changed } [ relayout-1 ] }
    } ;

C: scroller ( gadget -- scroller )
    #! Wrap a scrolling pane around the gadget.
    {
        { [ <viewport> ] set-scroller-viewport @center }
        { [ <x-slider> ] set-scroller-x @bottom }
        { [ <y-slider> ] set-scroller-y @right }
    } make-frame*
    t over set-gadget-root?
    dup faint-boundary ;

: set-slider ( value page max slider -- )
    #! page/max/value are 3-vectors.
    [ [ gadget-orientation v. ] keep set-slider-max ] keep
    [ [ gadget-orientation v. ] keep set-slider-page ] keep
    [ [ gadget-orientation v. ] keep set-slider-value* ] keep
    slider-elevator relayout-1 ;

: update-slider ( scroller value slider -- )
    >r swap scroller-viewport dup rect-dim swap viewport-dim
    r> set-slider ;

: scroll ( scroller value -- )
    2dup over scroller-x update-slider
    over scroller-y update-slider ;

: pop-follows ( scroller -- follows )
    dup scroller-follows f rot set-scroller-follows ;

: (do-scroll) ( gadget viewport -- point )
    [ [ swap relative-rect ] keep rect-union ] keep
    [ rect-extent v+ ] 2apply v- ;

: do-scroll ( scroller -- delta )
    dup pop-follows dup [
        swap scroller-viewport (do-scroll)
    ] [
        2drop { 0 0 }
    ] if ;

: update-scroller ( scroller -- )
    [ dup do-scroll ] keep scroller-origin v+ scroll ;

: position-viewport ( scroller -- )
    dup scroller-origin vneg
    swap scroller-viewport gadget-child
    set-rect-loc ;

M: scroller layout* ( scroller -- )
    dup delegate layout*
    dup layout-children
    dup update-scroller position-viewport ;

M: scroller focusable-child* ( scroller -- viewport )
    scroller-viewport ;

: scroller-gadget ( scroller -- gadget )
    #! Gadget being scrolled.
    scroller-viewport gadget-child ;
