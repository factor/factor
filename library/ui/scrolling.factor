IN: gadgets
USING: kernel lists math namespaces threads ;

! A viewport can be scrolled.

TUPLE: viewport x y delegate ;

: viewport-h ( viewport -- h ) gadget-children max-height ;
: viewport-w ( viewport -- w ) gadget-children max-width ;

: adjust-scroll ( y viewport -- y )
    #! Make sure we don't scroll above the first line, or beyond
    #! the end of the document.
    dup shape-h swap viewport-h - max 0 min ;

: scroll-viewport ( y viewport -- )
    #! y is a number between 0 and 1.
    [ viewport-h * >fixnum ] keep
    [ adjust-scroll ] keep
    [ set-viewport-y ] keep
    relayout ;

: scroll>bottom ( viewport -- )
    1 swap scroll-viewport ;

: viewport-actions ( viewport -- )
    {{
        [[ [ scroll>bottom ] [ scroll>bottom ] ]]
    }} clone swap set-gadget-gestures ;

C: viewport ( content -- viewport )
    [ <empty-gadget> swap set-viewport-delegate ] keep
    [ add-gadget ] keep
    0 over set-viewport-x
    0 over set-viewport-y
    dup viewport-actions
    640 480 pick resize-gadget ;

M: viewport layout* ( viewport -- )
    dup gadget-children [
        2dup
        >r dup viewport-x swap viewport-y r> move-gadget
        [ dup shape-h >r swap shape-w swap shape-w max r> ] keep
        resize-gadget
    ] each-with ;

: scroll>bottom ( viewport -- )
    dup viewport-h swap scroll-viewport ;

! A slider scrolls a viewport.

! The offset slot is the y co-ordinate of the mouse relative to
! the thumb when it was clicked.
TUPLE: slider viewport thumb offset delegate ;

TUPLE: thumb offset delegate ;

: hand-y ( gadget -- y )
    #! Vertical offset of hand from gadget.
    my-hand swap relative shape-y ;

: thumb-click ( thumb -- )
    [ hand-y ] keep set-thumb-offset ;

: thumb-drag ( thumb -- y )
    [ gadget-parent hand-y ] keep thumb-offset - ;

: thumb-motion ( thumb -- )
    dup thumb-drag over gadget-parent shape-h /
    over gadget-parent slider-viewport scroll-viewport
    relayout ;

: thumb-actions ( thumb -- )
    dup
    [ thumb-click ] [ button-down 1 ] set-action
    [ thumb-motion ] [ drag ] set-action ;

C: thumb ( -- thumb )
    0 0 0 0 <plain-rect> <gadget> over set-thumb-delegate
    dup t reverse-video set-paint-property
    dup thumb-actions ;

: add-thumb ( thumb slider -- )
    2dup add-gadget set-slider-thumb ;

: slider-size 20 ;

: slider-click ( slider -- )
    [ dup hand-y swap shape-h / ] keep
    [ slider-viewport scroll-viewport ] keep
    relayout ;

: slider-actions ( slider -- )
    [ slider-click ] [ button-down 1 ] set-action ;

C: slider ( viewport -- slider )
    [ set-slider-viewport ] keep
    [
        f line-border
        slider-size 200 pick resize-gadget
        swap set-slider-delegate
    ] keep
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

M: slider layout* ( slider -- )
    dup slider-viewport layout*
    dup shape-w over thumb-height pick slider-thumb resize-gadget
    0 over thumb-y rot slider-thumb move-gadget ;

TUPLE: scroller viewport slider delegate ;

: add-viewport 2dup set-scroller-viewport add-gadget ;
: add-slider 2dup set-scroller-slider add-gadget ;

C: scroller ( gadget -- scroller )
    #! Wrap a scrolling pane around the gadget.
    [ <line-shelf> swap set-scroller-delegate ] keep
    [ >r <viewport> r> add-viewport ] keep
    [ dup scroller-viewport <slider> swap add-slider ] keep ;
