! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-scrolling
USING: arrays gadgets gadgets-theme gadgets-viewports
gadgets-sliders generic kernel math namespaces sequences
models ;

TUPLE: scroller viewport x y follows model ;

: find-scroller ( gadget -- scroller/f )
    [ scroller? ] find-parent ;

: scroll-up-page scroller-y -1 swap slide-by-page ;

: scroll-down-page scroller-y 1 swap slide-by-page ;

: scroll-up-line scroller-y -1 swap slide-by-line ;

: scroll-down-line scroller-y 1 swap slide-by-line ;

: do-mouse-scroll ( scroller -- )
    scroll-direction get-global first2
    pick scroller-y slide-by-line
    swap scroller-x slide-by-line ;

scroller H{
    { T{ mouse-scroll } [ do-mouse-scroll ] }
} set-gestures

: init-scroller-model ( scroller -- )
    dup scroller-x control-model
    over scroller-y control-model
    2array <compose> swap set-scroller-model ;

: scroller-value ( scroller -- loc )
    scroller-model model-value ;

C: scroller ( gadget -- scroller )
    {
        { [ <x-slider> ] set-scroller-x f @bottom }
        { [ <y-slider> ] set-scroller-y f @right  }
        {
            [
                gadget get
                dup init-scroller-model
                scroller-model <viewport>
            ]
            set-scroller-viewport f @center
        }
    } make-frame*
    t over set-gadget-root?
    dup faint-boundary ;

: update-slider ( scroller value slider -- )
    >r swap scroller-viewport dup rect-dim swap viewport-dim
    r> set-slider ;

: scroll ( scroller value -- )
    2dup
    over scroller-x update-slider
    over scroller-y update-slider ;

: (scroll>rect) ( rect scroller -- )
    [
        scroller-value vneg offset-rect
        viewport-gap offset-rect
    ] keep
    [
        scroller-viewport 2rect-extent
        >r >r v- { 0 0 } vmin r> r> v- { 0 0 } vmax v+
    ] keep dup scroller-value rot v+ scroll ;

: relative-scroll-rect ( rect gadget scroller -- newrect )
    scroller-viewport gadget-child relative-loc offset-rect ;

: scroll>rect ( rect gadget -- )
    dup find-scroller dup [
        [ relative-scroll-rect ] keep
        [ set-scroller-follows ] keep
        relayout
    ] [
        3drop
    ] if ;

: scroll>bottom ( gadget -- )
    find-scroller [
        t over set-scroller-follows relayout
    ] when* ;

: (scroll>bottom) ( scroller -- )
    dup scroller-viewport viewport-dim { 0 1 } v* scroll ;

: scroll>top ( gadget -- )
    <zero-rect> swap scroll>rect ;

: update-scroller ( scroller -- )
    dup scroller-follows [
        dup scroller-follows t eq? [
            dup (scroll>bottom)
        ] [
            dup scroller-follows over (scroll>rect)
        ] if
        f swap set-scroller-follows
    ] [
        dup scroller-value scroll
    ] if ;

M: scroller layout*
    dup delegate layout*
    dup layout-children
    update-scroller ;

M: scroller focusable-child*
    scroller-viewport ;
