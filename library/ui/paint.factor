! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables io kernel lists math matrices
namespaces sdl sequences strings styles ;

SYMBOL: clip

: >sdl-rect ( rectangle -- sdlrect )
    [ shape-x ] keep [ shape-y ] keep [ shape-w ] keep shape-h
    make-rect ;

: set-clip ( rect -- ? )
    #! The top/left corner of the clip rectangle is the location
    #! of the gadget on the screen. The bottom/right is the
    #! intersected clip rectangle. Return f if the clip region
    #! is an empty region.
    surface get swap >sdl-rect SDL_SetClipRect ;

: with-clip ( shape quot -- )
    #! All drawing done inside the quotation is clipped to the
    #! shape's bounds. The quotation is called with a boolean
    #! that is set to false if the gadget is entirely clipped.
    [
        >r screen-bounds clip [ intersect dup ] change set-clip
        r> call
    ] with-scope ; inline

GENERIC: draw-gadget* ( gadget -- )

: draw-gadget ( gadget -- )
    dup [
        [
            dup draw-gadget* dup [
                gadget-children [ draw-gadget ] each
            ] with-trans
        ] [ drop ] ifte
    ] with-clip ;

M: gadget draw-gadget* ( gadget -- ) drop ;

: paint-prop* ( gadget key -- value )
    swap gadget-paint ?hash ;

: paint-prop ( gadget key -- value )
    over [
        2dup paint-prop* dup [
            2nip
        ] [
            drop >r gadget-parent r> paint-prop
        ] ifte
    ] [
        2drop f
    ] ifte ;

: set-paint-prop ( gadget value key -- )
    pick gadget-paint ?set-hash swap set-gadget-paint ;

: fg ( gadget -- color )
    dup reverse-video paint-prop
    background foreground ? paint-prop ;

: bg ( gadget -- color )
    dup reverse-video paint-prop [
        foreground
    ] [
        dup rollover paint-prop rollover-bg background ?
    ] ifte paint-prop ;

: plain-rect ( shape -- )
    #! Draw a filled rect with the bounds of an arbitrary shape.
    [ rect>screen ] keep bg rgb boxColor ;

M: plain-gadget draw-gadget* ( gadget -- )
    >r surface get r> plain-rect ;

: hollow-rect ( shape -- )
    #! Draw a hollow rect with the bounds of an arbitrary shape.
    [ rect>screen >r 1 - r> 1 - ] keep fg rgb rectangleColor ;

M: etched-gadget draw-gadget* ( gadget -- )
    >r surface get r> 2dup plain-rect hollow-rect ;
