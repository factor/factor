! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces threads ;

! A viewport can be scrolled.

TUPLE: viewport x y ;

: viewport-h ( viewport -- h ) gadget-child pref-size nip ;

: adjust-scroll ( y viewport -- y )
    #! Make sure we don't scroll above the first line, or beyond
    #! the end of the document.
    dup shape-h swap viewport-h - max 0 min ;

: scroll-viewport ( y viewport -- )
    #! y is a number between -1 and 0..
    [ viewport-h * >fixnum ] keep
    [ adjust-scroll ] keep
    [ set-viewport-y ] keep
    relayout ;

C: viewport ( content -- viewport )
    [ <empty-gadget> swap set-delegate ] keep
    [ add-gadget ] keep
    0 over set-viewport-x
    0 over set-viewport-y ;

M: viewport pref-size gadget-child pref-size ;

M: viewport layout* ( viewport -- )
    dup gadget-child dup prefer
    >r dup viewport-x swap viewport-y r> move-gadget ;

! A slider scrolls a viewport.

! The offset slot is the y co-ordinate of the mouse relative to
! the thumb when it was clicked.
TUPLE: slider viewport thumb ;

: hand-y ( gadget -- y )
    #! Vertical offset of hand from gadget.
    hand swap relative shape-y ;

: slider-drag ( slider -- y )
    hand-y hand hand-click-rel shape-y + ;

: slider-motion ( thumb -- )
    dup slider-drag over shape-h /
    over slider-viewport scroll-viewport
    relayout ;

: thumb-actions ( thumb -- )
    dup [ drop ] [ button-down 1 ] set-action
    dup [ drop ] [ button-up 1 ] set-action
    [ gadget-parent slider-motion ] [ drag 1 ] set-action ;

: <thumb> ( -- thumb )
    0 0 0 0 <plain-rect> <gadget>
    dup t reverse-video set-paint-prop
    dup thumb-actions ;

: add-thumb ( thumb slider -- )
    2dup add-gadget set-slider-thumb ;

: slider-size 16 ;

: slider-click ( slider -- )
    [ dup hand-y swap shape-h / ] keep
    [ slider-viewport scroll-viewport ] keep
    relayout ;

: slider-actions ( slider -- )
    [ slider-click ] [ button-down 1 ] set-action ;

C: slider ( viewport -- slider )
    [ set-slider-viewport ] keep
    [ f line-border swap set-delegate ] keep
    [ <thumb> swap add-thumb ] keep
    [ slider-actions ] keep ;

: visible-portion ( viewport -- rational )
    #! Visible portion, between 0 and 1.
    [ shape-h ] keep viewport-h 1 max / 1 min ;

: >thumb ( slider y -- y )
    #! Convert a y co-ordinate in the viewport to a thumb
    #! position.
    swap slider-viewport visible-portion * >fixnum ;

: thumb-height ( slider -- h )
    dup shape-h [ >thumb slider-size max ] keep min ;

: thumb-y ( slider -- y )
    dup slider-viewport viewport-y neg >thumb ;

M: slider pref-size drop slider-size 100 ;

M: slider layout* ( slider -- )
    dup shape-w over thumb-height pick slider-thumb resize-gadget
    0 over thumb-y rot slider-thumb move-gadget ;

TUPLE: scroller viewport slider ;

: add-viewport 2dup set-scroller-viewport add-center ;
: add-slider 2dup set-scroller-slider add-right ;

: viewport>bottom -1 swap scroll-viewport ;
: (scroll>bottom) ( scroller -- )
    dup scroller-viewport viewport>bottom
    scroller-slider relayout ;

: scroll>bottom ( gadget -- )
    [ scroll>bottom ] swap handle-gesture drop ;

: scroller-actions ( scroller -- )
    [ (scroll>bottom) ] [ scroll>bottom ] set-action ;

C: scroller ( gadget -- scroller )
    #! Wrap a scrolling pane around the gadget.
    <frame> over set-delegate
    [ >r <viewport> r> add-viewport ] keep
    [ dup scroller-viewport <slider> swap add-slider ] keep
    dup scroller-actions ;
