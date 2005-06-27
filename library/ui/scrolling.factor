! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math matrices namespaces sequences
threads vectors styles ;

! A viewport can be scrolled.

TUPLE: viewport origin ;

: viewport-x viewport-origin first ;
: viewport-y viewport-origin second ;
: set-viewport-x [ viewport-y 0 3vector ] keep set-viewport-origin ;
: set-viewport-y [ viewport-x swap 0 3vector ] keep set-viewport-origin ;

: viewport-h ( viewport -- h ) gadget-child pref-size nip ;

: viewport-dim ( viewport -- h ) gadget-child pref-dim ;

: fix-scroll ( origin viewport -- origin )
    dup shape-dim swap viewport-dim v- vmax { 0 0 0 } vmin ;

: scroll ( origin viewport -- )
    [ fix-scroll ] keep [ set-viewport-origin ] keep relayout ;

: scroll-viewport ( y viewport -- )
    #! y is a number between -1 and 0..
    [ viewport-h * >fixnum ] keep
    [ viewport-x swap 0 3vector ] keep 
    scroll ;

C: viewport ( content -- viewport )
    [ <empty-gadget> swap set-delegate ] keep
    [ add-gadget ] keep
    { 0 0 0 } over set-viewport-origin ;

M: viewport pref-size gadget-child pref-size ;

M: viewport layout* ( viewport -- )
    dup viewport-origin
    swap gadget-child dup prefer set-gadget-loc ;

: visible-portion ( viewport -- vector )
    dup shape-dim { 1 1 1 } vmax
    swap viewport-dim { 1 1 1 } vmax
    v/ { 1 1 1 } vmin ;

! A slider scrolls a viewport.

! The offset slot is the y co-ordinate of the mouse relative to
! the thumb when it was clicked.
TUPLE: slider viewport thumb vector ;

: >thumb ( pos slider -- pos )
    slider-viewport visible-portion v* ;

: >viewport ( pos slider -- pos )
    slider-viewport visible-portion v/ ;

: slider-current ( slider -- pos )
    dup slider-viewport viewport-origin
    dup rot slider-vector v* v- ;

: slider-pos ( slider pos -- pos )
    hand pick relative v+ over slider-vector v* swap >viewport ;

: slider-click ( slider pos -- )
    dupd slider-pos over slider-current v+
    over slider-viewport scroll relayout ;

: slider-motion ( slider -- )
    hand hand-click-rel slider-click ;

: thumb-actions ( thumb -- )
    dup [ drop ] [ button-down 1 ] set-action
    dup [ drop ] [ button-up 1 ] set-action
    [ gadget-parent slider-motion ] [ drag 1 ] set-action ;

: <thumb> ( -- thumb )
    <plain-gadget>
    dup gray background set-paint-prop
    dup thumb-actions ;

: add-thumb ( thumb slider -- )
    2dup add-gadget set-slider-thumb ;

: slider-actions ( slider -- )
    [ { 0 0 0 } slider-click ] [ button-down 1 ] set-action ;

C: slider ( viewport vector -- slider )
    [ set-slider-vector ] keep
    [ set-slider-viewport ] keep
    f line-border over set-delegate
    <thumb> over add-thumb
    dup slider-actions ;

: <x-slider> ( viewport -- slider ) { 1 0 0 } <slider> ;

: <y-slider> ( viewport -- slider ) { 0 1 0 } <slider> ;

: thumb-loc ( slider -- loc )
    dup slider-viewport viewport-origin vneg swap >thumb ;

: slider-dim { 16 16 16 } ;

: thumb-dim ( slider -- h )
    [ shape-dim dup ] keep >thumb slider-dim vmax vmin ;

M: slider pref-size drop slider-dim 3unseq drop ;

M: slider layout* ( slider -- )
    dup thumb-loc over slider-vector v*
    over slider-thumb set-gadget-loc
    dup thumb-dim over slider-vector v* slider-dim vmax
    swap slider-thumb set-gadget-dim ;

TUPLE: scroller viewport x y ;

: add-viewport 2dup set-scroller-viewport add-center ;

: add-x-slider 2dup set-scroller-x add-bottom ;

: add-y-slider 2dup set-scroller-y add-right ;

: viewport>bottom -1 swap scroll-viewport ;

: (scroll>bottom) ( scroller -- )
    dup scroller-viewport viewport>bottom
    dup scroller-x relayout scroller-y relayout ;

: scroll>bottom ( gadget -- )
    [ scroll>bottom ] swap handle-gesture drop ;

: scroller-actions ( scroller -- )
    [ (scroll>bottom) ] [ scroll>bottom ] set-action ;

C: scroller ( gadget -- scroller )
    #! Wrap a scrolling pane around the gadget.
    <frame> over set-delegate
    [ >r <viewport> r> add-viewport ] keep
    dup scroller-viewport <x-slider> over add-x-slider
    dup scroller-viewport <y-slider> over add-y-slider
    dup scroller-actions ;
