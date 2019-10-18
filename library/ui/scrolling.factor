! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math matrices namespaces sequences
threads vectors styles ;

! A viewport can be scrolled.
TUPLE: viewport origin bottom? ;

! A slider scrolls a viewport.
TUPLE: slider thumb vector ;

! A scroller combines a viewport with two x and y sliders.
TUPLE: scroller viewport x y ;

: viewport-dim gadget-child pref-dim ;

: fix-scroll ( origin viewport -- origin )
    dup rectangle-dim swap viewport-dim v- vmax { 0 0 0 } vmin ;

: scroll-viewport ( origin viewport -- )
    [ fix-scroll ] keep [ set-viewport-origin ] keep relayout ;

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
    set-rectangle-loc ;

M: viewport focusable-child* ( viewport -- gadget )
    gadget-child ;

: visible-portion ( viewport -- vector )
    dup rectangle-dim { 1 1 1 } vmax
    swap viewport-dim { 1 1 1 } vmax
    v/ { 1 1 1 } vmin ;

: slider-scroller ( slider -- scroller )
    [ scroller? ] find-parent ;

: slider-viewport ( slider -- viewport )
    slider-scroller scroller-viewport ;

: >thumb ( pos slider -- pos )
    slider-viewport visible-portion v* ;

: >viewport ( pos slider -- pos )
    slider-viewport visible-portion v/ ;

: slider-current ( slider -- pos )
    dup slider-viewport viewport-origin*
    dup rot slider-vector v* v- ;

: slider-pos ( slider pos -- pos )
    hand pick relative v+ over slider-vector v* swap >viewport ;

: scroll ( origin scroller -- )
    [ scroller-viewport scroll-viewport ] keep
    dup scroller-x relayout scroller-y relayout ;

: slider-click ( slider pos -- )
    dupd slider-pos over slider-current v+
    swap slider-scroller scroll ;

: slider-motion ( slider -- )
    hand hand-click-rel slider-click ;

: thumb-actions ( thumb -- )
    dup [ drop ] [ button-down 1 ] set-action
    dup [ drop ] [ button-up 1 ] set-action
    [ gadget-parent slider-motion ] [ drag 1 ] set-action ;

: <thumb> ( -- thumb )
    <bevel-gadget>
    t over set-gadget-root?
    dup [ 192 192 192 ] background set-paint-prop
    dup thumb-actions ;

: add-thumb ( thumb slider -- )
    2dup add-gadget set-slider-thumb ;

: slider-actions ( slider -- )
    [ { 0 0 0 } slider-click ] [ button-down 1 ] set-action ;

C: slider ( vector -- slider )
    <plain-gadget> over set-delegate
    dup [ 128 128 128 ] background set-paint-prop
    [ set-slider-vector ] keep
    <thumb> over add-thumb
    dup slider-actions ;

: <x-slider> ( -- slider ) { 1 0 0 } <slider> ;

: <y-slider> ( -- slider ) { 0 1 0 } <slider> ;

: thumb-loc ( slider -- loc )
    dup slider-viewport
    dup viewport-origin* swap fix-scroll
    vneg swap >thumb ;

: slider-dim { 12 12 12 } ;

: thumb-dim ( slider -- h )
    [ rectangle-dim dup ] keep >thumb slider-dim vmax vmin ;

M: slider pref-dim drop slider-dim ;

M: slider layout* ( slider -- )
    dup thumb-loc over slider-vector v*
    over slider-thumb set-rectangle-loc
    dup thumb-dim over slider-vector v* slider-dim vmax
    swap slider-thumb set-gadget-dim ;

: add-viewport 2dup set-scroller-viewport add-center ;

: add-x-slider 2dup set-scroller-x add-bottom ;

: add-y-slider 2dup set-scroller-y add-right ;

: (scroll>bottom) ( scroller -- )
    t over scroller-viewport set-viewport-bottom?
    dup scroller-x relayout scroller-y relayout ;

: scroll>bottom ( gadget -- )
    [ scroll>bottom ] swap handle-gesture drop ;

: scroll-by ( scroller amount -- )
    over scroller-viewport viewport-origin v+ swap scroll ;

: scroller-actions ( scroller -- )
    dup [ (scroll>bottom) ] [ scroll>bottom ] set-action
    dup [ { 0 32 0 } scroll-by ] [ button-down 4 ] set-action
    [ { 0 -32 0 } scroll-by ] [ button-down 5 ] set-action ;

C: scroller ( gadget -- scroller )
    #! Wrap a scrolling pane around the gadget.
    <frame> over set-delegate
    [ >r <viewport> r> add-viewport ] keep
    <x-slider> over add-x-slider
    <y-slider> over add-y-slider
    dup scroller-actions ;

M: scroller focusable-child* ( viewport -- gadget )
    scroller-viewport ;
