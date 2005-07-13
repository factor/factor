! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables io kernel lists math matrices
namespaces sdl sequences strings ;

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

: draw-gadget ( gadget -- )
    #! All drawing done inside draw-shape is done with the
    #! gadget's paint. If the gadget does not have any custom
    #! paint, just call the quotation.
    dup gadget-paint [
        dup [
            [
                dup draw-shape dup [
                    gadget-children [ draw-gadget ] each
                ] with-trans
            ] [ drop ] ifte
        ] with-clip
    ] bind ;
