! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ui.gadgets ui.gadgets.viewports
ui.gadgets.frames ui.gadgets.grids ui.gadgets.theme
ui.gadgets.sliders ui.gestures kernel math namespaces sequences
models models.range models.compose
combinators math.vectors classes.tuple math.geometry.rect
combinators.short-circuit ;
IN: ui.gadgets.scrollers

TUPLE: scroller < frame viewport x y follows ;

: find-scroller ( gadget -- scroller/f )
    [ scroller? ] find-parent ;

: scroll-up-page ( scroller -- ) y>> -1 swap slide-by-page ;

: scroll-down-page ( scroller -- ) y>> 1 swap slide-by-page ;

: scroll-up-line ( scroller -- ) y>> -1 swap slide-by-line ;

: scroll-down-line ( scroller -- ) y>> 1 swap slide-by-line ;

: do-mouse-scroll ( scroller -- )
    scroll-direction get-global first2
    pick y>> slide-by-line
    swap x>> slide-by-line ;

scroller H{
    { T{ mouse-scroll } [ do-mouse-scroll ] }
} set-gestures

: <scroller-model> ( -- model )
    0 0 0 0 <range> 0 0 0 0 <range> 2array <compose> ;

: new-scroller ( gadget class -- scroller )
    new-frame
        t >>root?
        <scroller-model> >>model
        faint-boundary

        dup model>> dependencies>> first  <x-slider> >>x dup x>> @bottom grid-add
        dup model>> dependencies>> second <y-slider> >>y dup y>> @right  grid-add

        tuck model>> <viewport> >>viewport
        dup viewport>> @center grid-add ; inline

: <scroller> ( gadget -- scroller ) scroller new-scroller ;

: scroll ( value scroller -- )
    [
        dup viewport>> rect-dim { 0 0 }
        rot viewport>> viewport-dim 4array flip
    ] keep
    2dup control-value = [ 2drop ] [ set-control-value ] if ;

: rect-min ( rect dim -- rect' )
    [ [ loc>> ] [ dim>> ] bi ] dip vmin <rect> ;

: (scroll>rect) ( rect scroller -- )
    [
        scroller-value vneg offset-rect
        viewport-gap offset-rect
    ] keep
    [ viewport>> dim>> rect-min ] keep
    [
        viewport>> 2rect-extent
        [ v- { 1 1 } v- { 0 0 } vmin ] [ v- { 0 0 } vmax ] 2bi* v+
    ] keep dup scroller-value rot v+ swap scroll ;

: relative-scroll-rect ( rect gadget scroller -- newrect )
    viewport>> gadget-child relative-loc offset-rect ;

: find-scroller* ( gadget -- scroller/f )
    dup find-scroller
    { [ nip ] [ viewport>> gadget-child swap child? ] [ nip ] }
    2&& ;

: scroll>rect ( rect gadget -- )
    dup find-scroller* dup [
        [ relative-scroll-rect ] keep
        swap >>follows
        relayout
    ] [
        3drop
    ] if ;

: (scroll>gadget) ( gadget scroller -- )
    >r { 0 0 } over pref-dim <rect> swap r>
    [ relative-scroll-rect ] keep
    (scroll>rect) ;

: scroll>gadget ( gadget -- )
    dup find-scroller* dup [
        swap >>follows
        relayout
    ] [
        2drop
    ] if ;

: (scroll>bottom) ( scroller -- )
    dup viewport>> viewport-dim { 0 1 } v* swap scroll ;

: scroll>bottom ( gadget -- )
    find-scroller [ t >>follows relayout-1 ] when* ;

: scroll>top ( gadget -- )
    <zero-rect> swap scroll>rect ;

GENERIC: update-scroller ( scroller follows -- )

M: t update-scroller drop (scroll>bottom) ;

M: gadget update-scroller swap (scroll>gadget) ;

M: rect update-scroller swap (scroll>rect) ;

M: f update-scroller drop dup scroller-value swap scroll ;

M: scroller layout*
    dup call-next-method
    dup follows>>
    2dup update-scroller
    >>follows drop ;

M: scroller focusable-child*
    viewport>> ;

M: scroller model-changed
    nip f >>follows drop ;

TUPLE: limited-scroller < scroller
{ min-dim initial: { 0 0 } }
{ max-dim initial: { 1/0. 1/0. } } ;

: <limited-scroller> ( gadget -- scroller )
    limited-scroller new-scroller ;

M: limited-scroller pref-dim*
    [ call-next-method ] [ min-dim>> vmax ] [ max-dim>> vmin ] tri ;
