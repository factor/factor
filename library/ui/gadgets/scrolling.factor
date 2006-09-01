! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-scrolling
USING: arrays gadgets gadgets-frames gadgets-theme
gadgets-viewports generic kernel math namespaces sequences ;

! A scroller combines a viewport with two x and y sliders.
! The follows slot is a boolean, if true scroller will scroll
! down on the next relayout.
TUPLE: scroller viewport x y follows ;

: scroller-origin ( scroller -- point )
    dup scroller-x slider-value
    swap scroller-y slider-value
    2array ;

: find-scroller [ scroller? ] find-parent ;

: scroll-up-line scroller-y -1 swap slide-by-line ;

: scroll-down-line scroller-y 1 swap slide-by-line ;

scroller H{
    { T{ wheel-up } [ scroll-up-line ] }
    { T{ wheel-down } [ scroll-down-line ] }
    { T{ slider-changed } [ relayout-1 ] }
} set-gestures

C: scroller ( gadget -- scroller )
    #! Wrap a scrolling pane around the gadget.
    {
        { [ <viewport> ] set-scroller-viewport f @center }
        { [ <x-slider> ] set-scroller-x        f @bottom }
        { [ <y-slider> ] set-scroller-y        f @right  }
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

: position-viewport ( scroller -- )
    dup scroller-origin vneg
    swap scroller-viewport gadget-child
    set-rect-loc ;

: scroll ( scroller value -- )
    2dup over scroller-x update-slider
    dupd over scroller-y update-slider
    position-viewport ;

: (scroll>rect) ( rect scroller -- )
    [ scroller-origin vneg offset-rect viewport-rect ] keep
    [
        scroller-viewport 2rect-extent
        >r >r v- { 0 0 } vmin r> r> v- { 0 0 } vmax v+
    ] keep dup scroller-origin rot v+ scroll ;

: scroll>rect ( rect gadget -- )
    find-scroller dup [ [ set-scroller-follows ] 2keep ] when
    relayout drop ;

: scroll>bottom ( gadget -- )
    t swap scroll>rect ;

: (scroll>bottom) ( scroller -- )
    dup scroller-viewport viewport-dim { 0 1 } v* scroll ;

: update-scroller ( scroller -- )
    dup scroller-follows [
        dup scroller-follows t eq? [
            dup (scroll>bottom)
        ] [
            dup scroller-follows over (scroll>rect)
        ] if
        f swap set-scroller-follows
    ] [
        dup scroller-origin scroll
    ] if ;

M: scroller layout*
    dup delegate layout*
    dup layout-children
    update-scroller ;

M: scroller focusable-child*
    scroller-viewport ;
