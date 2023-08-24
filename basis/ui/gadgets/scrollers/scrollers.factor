! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.short-circuit
kernel math.rectangles math.vectors models models.product
models.range namespaces sequences ui.gadgets ui.gadgets.frames
ui.gadgets.grids ui.gadgets.private ui.gadgets.sliders
ui.gadgets.viewports ui.gestures ;
IN: ui.gadgets.scrollers

TUPLE: scroller < frame column-header viewport x y follows ;

! Scrollable gadget protocol; optional
GENERIC: pref-viewport-dim ( gadget -- dim )

M: gadget pref-viewport-dim pref-dim ;

GENERIC: viewport-column-header ( gadget -- gadget/f )

M: gadget viewport-column-header drop f ;

: find-scroller ( gadget -- scroller/f )
    [ scroller? ] find-parent ;

: scroll-up-page ( scroller -- ) y>> -1 swap slide-by-page ;

: scroll-down-page ( scroller -- ) y>> 1 swap slide-by-page ;

: scroll-up-line ( scroller -- ) y>> -1 swap slide-by-line ;

: scroll-down-line ( scroller -- ) y>> 1 swap slide-by-line ;

: set-scroll-position ( value scroller -- )
    [
        viewport>> [ dim>> { 0 0 } ] [ gadget-child pref-dim ] bi
        4array flip
    ] keep
    2dup control-value = [ 2drop ] [ set-control-value ] if ;

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
    0 0 0 0 1 <range> 0 0 0 0 1 <range> 2array <product> ;

M: viewport pref-dim* gadget-child pref-viewport-dim ;

: (scroll>rect) ( rect scroller -- )
    {
        [ scroll-position vneg offset-rect ]
        [ viewport>> dim>> rect-min ]
        [ viewport>> loc>> offset-rect ]
        [ viewport>> [ v- { 0 0 } vmin ] [ v- { 0 0 } vmax ] with-rect-extents v+ ]
        [ scroll-position v+ ]
        [ set-scroll-position ]
    } cleave ;

: relative-scroll-rect ( rect gadget scroller -- newrect )
    viewport>> gadget-child relative-loc offset-rect ;

: find-scroller* ( gadget -- scroller/f )
    dup find-scroller
    { [ nip ] [ viewport>> gadget-child swap child? ] [ nip ] }
    2&& ;

: (update-scroller) ( scroller -- )
    [ scroll-position ] keep set-scroll-position ;

: (scroll>gadget) ( gadget scroller -- )
    2dup swap child? [
        [ [ [ { 0 0 } ] dip pref-dim <rect> ] keep ] dip
        [ relative-scroll-rect ] keep
        (scroll>rect)
    ] [ f >>follows (update-scroller) drop ] if ;

: (scroll>bottom) ( scroller -- )
    [ viewport>> gadget-child pref-dim { 0 1 } v* ] keep
    set-scroll-position ;

GENERIC: update-scroller ( scroller follows -- )

M: t update-scroller drop (scroll>bottom) ;

M: gadget update-scroller swap (scroll>gadget) ;

M: rect update-scroller swap (scroll>rect) ;

M: f update-scroller drop (update-scroller) ;

M: scroller layout*
    {
        [ call-next-method ]
        [ dup follows>> [ update-scroller ] [ >>follows drop ] 2bi ]
        [ [ x>> ] [ y>> ] bi [ forget-pref-dim ] bi@ ]
        [ call-next-method ]
    } cleave ;

M: scroller focusable-child*
    viewport>> ;

M: scroller model-changed
    f >>follows 2drop ;

: build-scroller ( scroller -- scroller )
    dup x>> { 0 1 } grid-add
    dup y>> { 1 0 } grid-add
    dup viewport>> { 0 0 } grid-add ; inline

: <column-header-viewport> ( scroller -- viewport )
    [ column-header>> ] [ model>> ] bi
    <viewport> horizontal >>constraint ;

: build-header-scroller ( scroller -- scroller )
    dup <column-header-viewport> { 0 0 } grid-add
    dup x>> { 0 2 } grid-add
    dup y>> { 1 1 } grid-add
    dup viewport>> { 0 1 } grid-add ; inline

: init-scroller ( column-header scroller -- scroller )
    over { 0 1 } { 0 0 } ? >>filled-cell
    t >>root?
    <scroller-model> >>model
    swap >>column-header ; inline

: build-children ( gadget scroller -- scroller )
    dup model>> dependencies>>
    [ first horizontal <slider> >>x ]
    [ second vertical <slider> >>y ] bi
    [ nip ] [ model>> <viewport> ] 2bi >>viewport ; inline

PRIVATE>

: <scroller> ( gadget -- scroller )
    dup viewport-column-header
    dup [ 2 3 ] [ 2 2 ] if scroller new-frame
        init-scroller
        build-children
        dup column-header>>
        [ build-header-scroller ] [ build-scroller ] if ;

: scroll>rect ( rect gadget -- )
    dup find-scroller* [
        [ relative-scroll-rect ] keep
        swap >>follows
        relayout-1
    ] [ 2drop ] if* ;

: scroll>gadget ( gadget -- )
    dup find-scroller* [
        swap >>follows
        relayout-1
    ] [
        drop
    ] if* ;

: scroll>bottom ( gadget -- )
    find-scroller [ t >>follows relayout-1 ] when* ;

: scroll>top ( gadget -- )
    <zero-rect> swap scroll>rect ;
