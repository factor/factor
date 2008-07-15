! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ui.gadgets ui.gadgets.viewports
ui.gadgets.frames ui.gadgets.grids ui.gadgets.theme
ui.gadgets.sliders ui.gestures kernel math namespaces sequences
models models.range models.compose
combinators math.vectors classes.tuple math.geometry.rect ;
IN: ui.gadgets.scrollers

TUPLE: scroller < frame viewport x y follows ;

: find-scroller ( gadget -- scroller/f )
    [ [ scroller? ] is? ] find-parent ;

: scroll-up-page ( scroller -- ) y>> -1 swap slide-by-page ;

: scroll-down-page ( scroller -- ) y>> 1 swap slide-by-page ;

: scroll-up-line ( scroller -- ) y>> -1 swap slide-by-line ;

: scroll-down-line ( scroller -- ) y>> 1 swap slide-by-line ;

: do-mouse-scroll ( scroller -- )
    scroll-direction get-global first2
    pick scroller-y slide-by-line
    swap scroller-x slide-by-line ;

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

    dup model>> dependencies>> first  <x-slider> >>x dup x>> @bottom grid-add*
    dup model>> dependencies>> second <y-slider> >>y dup y>> @right  grid-add*

    swap over model>> <viewport> >>viewport
    dup viewport>> @center grid-add* ;
    
: <scroller> ( gadget -- scroller ) scroller new-scroller ;

: scroll ( value scroller -- )
    [
        dup scroller-viewport rect-dim { 0 0 }
        rot scroller-viewport viewport-dim 4array flip
    ] keep
    2dup control-value = [ 2drop ] [ set-control-value ] if ;

: rect-min ( rect1 rect2 -- rect )
    >r [ rect-loc ] keep r> [ rect-dim ] bi@ vmin <rect> ;

: (scroll>rect) ( rect scroller -- )
    [
        scroller-value vneg offset-rect
        viewport-gap offset-rect
    ] keep
    [ scroller-viewport rect-min ] keep
    [
        scroller-viewport 2rect-extent
        >r >r v- { 0 0 } vmin r> r> v- { 0 0 } vmax v+
    ] keep dup scroller-value rot v+ swap scroll ;

: relative-scroll-rect ( rect gadget scroller -- newrect )
    viewport>> gadget-child relative-loc offset-rect ;

: find-scroller* ( gadget -- scroller )
    dup find-scroller dup [
        2dup scroller-viewport gadget-child
        swap child? [ nip ] [ 2drop f ] if
    ] [
        2drop f
    ] if ;

: scroll>rect ( rect gadget -- )
    dup find-scroller* dup [
        [ relative-scroll-rect ] keep
        [ set-scroller-follows ] keep
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
        [ set-scroller-follows ] keep
        relayout
    ] [
        2drop
    ] if ;

: (scroll>bottom) ( scroller -- )
    dup scroller-viewport viewport-dim { 0 1 } v* swap scroll ;

: scroll>bottom ( gadget -- )
    find-scroller [
        t over set-scroller-follows relayout-1
    ] when* ;

: scroll>top ( gadget -- )
    <zero-rect> swap scroll>rect ;

GENERIC: update-scroller ( scroller follows -- )

M: t update-scroller drop (scroll>bottom) ;

M: gadget update-scroller swap (scroll>gadget) ;

M: rect update-scroller swap (scroll>rect) ;

M: f update-scroller drop dup scroller-value swap scroll ;

M: scroller layout*
    dup call-next-method
    dup scroller-follows
    [ update-scroller ] 2keep
    swap set-scroller-follows ;

M: scroller focusable-child*
    scroller-viewport ;

M: scroller model-changed
    nip f swap set-scroller-follows ;

TUPLE: limited-scroller < scroller fixed-dim ;

: <limited-scroller> ( gadget dim -- scroller )
    >r limited-scroller new-scroller r> >>fixed-dim ;

M: limited-scroller pref-dim*
    fixed-dim>> ;
