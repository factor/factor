IN: gadgets
USING: kernel lists math namespaces threads ;

! A viewport can be scrolled.

TUPLE: viewport x y delegate ;

C: viewport ( content -- viewport )
    [ <empty-gadget> swap set-viewport-delegate ] keep
    [ add-gadget ] keep
    0 over set-viewport-x
    0 over set-viewport-y
    200 200 pick resize-gadget ;

M: viewport layout* ( viewport -- )
    dup gadget-children [
        >r dup viewport-scroll-x swap viewport-scroll-y r>
        move-gadget
    ] each-with ;

: viewport-h ( viewport -- h ) gadget-children max-height ;
: viewport-w ( viewport -- w ) gadget-children max-width ;

: scroll-viewport ( y viewport -- )
    #! y is a number between 0 and 1.
    [ viewport-h * >fixnum ] keep
    [ set-viewport-y ] keep
    relayout ;

! A slider scrolls a viewport.

TUPLE: slider viewport thumb scrolling? delegate ;

: <thumb> ( -- thumb )
    f bevel-border
    dup t bevel-up? set-paint-property ;

: add-thumb ( thumb slider -- )
    2dup add-gadget set-slider-thumb ;

: slider-size 20 ;

: slider-motion ( slider -- )
    dup slider-scrolling? [
        dup screen-pos my-hand screen-pos - shape-y
        over shape-h / over slider-viewport scroll-viewport
        relayout
    ] [
        drop
    ] ifte ;

: slider-actions ( slider -- )
    dup [ slider-motion ] [ motion ] set-action
    dup [ t swap set-slider-scrolling? ] [ button-down 1 ] set-action
    [ f swap set-slider-scrolling? ] [ button-up 1 ] set-action ;

C: slider ( viewport -- slider )
    [ set-slider-viewport ] keep
    [
        f bevel-border dup f bevel-up? set-paint-property
        slider-size 200 pick resize-gadget
        swap set-slider-delegate
    ] keep
    [ <thumb> swap add-thumb ] keep
    [ slider-actions ] keep ;

: visible-portion ( viewport -- float )
    #! Visible portion, > 0, <= 1.
    dup shape-h swap viewport-h 1 max / 1 min ;

: >thumb ( slider y -- y )
    #! Convert a y co-ordinate in the viewport to a thumb
    #! position.
    swap slider-viewport visible-portion * >fixnum ;

: thumb-y ( slider -- y )
    dup slider-viewport viewport-y neg >thumb ;

: thumb-height ( slider -- h )
    dup shape-h [ >thumb slider-size max ] keep min ;

M: slider layout* ( slider -- )
    dup slider-viewport layout*
    dup shape-w over thumb-height pick slider-thumb resize-gadget
    0 over thumb-y rot slider-thumb move-gadget ;
