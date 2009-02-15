! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ui.gadgets ui.gadgets.viewports
ui.gadgets.frames ui.gadgets.grids
ui.gadgets.sliders ui.gestures kernel math namespaces sequences
models models.range models.compose combinators math.vectors
classes.tuple math.rectangles combinators.short-circuit ;
IN: ui.gadgets.scrollers

TUPLE: scroller < frame viewport x y follows ;

! Scrollable gadget protocol; optional
GENERIC: pref-viewport-dim ( gadget -- dim )

M: gadget pref-viewport-dim pref-dim ;

: find-scroller ( gadget -- scroller/f )
    [ scroller? ] find-parent ;

: scroll-up-page ( scroller -- ) y>> -1 swap slide-by-page ;

: scroll-down-page ( scroller -- ) y>> 1 swap slide-by-page ;

: scroll-up-line ( scroller -- ) y>> -1 swap slide-by-line ;

: scroll-down-line ( scroller -- ) y>> 1 swap slide-by-line ;

<PRIVATE

: do-mouse-scroll ( scroller -- )
    scroll-direction get-global
    [ first swap x>> slide-by-line ]
    [ second swap y>> slide-by-line ]
    2bi ;

scroller H{
    { mouse-scroll [ do-mouse-scroll ] }
} set-gestures

: <scroller-model> ( -- model )
    0 0 0 0 <range> 0 0 0 0 <range> 2array <compose> ;

M: viewport pref-dim* gadget-child pref-viewport-dim ;

: scroll ( value scroller -- )
    [
        viewport>> [ dim>> { 0 0 } ] [ gadget-child pref-dim ] bi
        4array flip
    ] keep
    2dup control-value = [ 2drop ] [ set-control-value ] if ;

: (scroll>rect) ( rect scroller -- )
    [ [ loc>> ] [ dim>> ] bi <rect> ] dip
    {
        [ scroller-value vneg offset-rect ]
        [ viewport>> dim>> rect-min ]
        [ viewport>> [ v- { 0 0 } vmin ] [ v- { 0 0 } vmax ] with-rect-extents v+ ]
        [ scroller-value v+ ]
        [ scroll ]
    } cleave ;

: relative-scroll-rect ( rect gadget scroller -- newrect )
    viewport>> gadget-child relative-loc offset-rect ;

: find-scroller* ( gadget -- scroller/f )
    dup find-scroller
    { [ nip ] [ viewport>> gadget-child swap child? ] [ nip ] }
    2&& ;

: (update-scroller) ( scroller -- )
    [ scroller-value ] keep scroll ;

: (scroll>gadget) ( gadget scroller -- )
    2dup swap child? [
        [ [ [ { 0 0 } ] dip pref-dim <rect> ] keep ] dip
        [ relative-scroll-rect ] keep
        (scroll>rect)
    ] [ f >>follows (update-scroller) drop ] if ;

: (scroll>bottom) ( scroller -- )
    [ viewport>> gadget-child pref-dim { 0 1 } v* ] keep scroll ;

GENERIC: update-scroller ( scroller follows -- )

M: t update-scroller drop (scroll>bottom) ;

M: gadget update-scroller swap (scroll>gadget) ;

M: rect update-scroller swap (scroll>rect) ;

M: f update-scroller drop (update-scroller) ;

M: scroller layout*
    [ call-next-method ] [
        dup follows>>
        [ update-scroller ] [ >>follows drop ] 2bi
    ] bi ; 

M: scroller focusable-child*
    viewport>> ;

M: scroller model-changed
    f >>follows 2drop ;

PRIVATE>

: <scroller> ( gadget -- scroller )
    2 2 scroller new-frame
        { 1 1 } >>gap
        { 0 0 } >>filled-cell
        t >>root?
        <scroller-model> >>model

        dup model>> dependencies>>
        [ first horizontal <slider> [ >>x ] [ { 0 1 } grid-add ] bi ]
        [ second vertical <slider> [ >>y ] [ { 1 0 } grid-add ] bi ] bi

        tuck model>> <viewport> [ >>viewport ] [ { 0 0 } grid-add ] bi ; inline

: scroll>rect ( rect gadget -- )
    dup find-scroller* dup [
        [ relative-scroll-rect ] keep
        swap >>follows
        relayout
    ] [ 3drop ] if ;

: scroll>gadget ( gadget -- )
    dup find-scroller* dup [
        swap >>follows
        relayout
    ] [
        2drop
    ] if ;

: scroll>bottom ( gadget -- )
    find-scroller [ t >>follows relayout-1 ] when* ;

: scroll>top ( gadget -- )
    <zero-rect> swap scroll>rect ;
