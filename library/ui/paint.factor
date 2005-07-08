! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math namespaces sdl
io strings sequences ;

: redraw ( gadget -- )
    #! Redraw a gadget before the next iteration of the event
    #! loop.
    dup gadget-redraw? [
        drop
    ] [
        t over set-gadget-redraw?
        gadget-parent [ redraw ] when*
    ] ifte ;

! Clipping

SYMBOL: clip

: intersect* ( gadget rect quot -- t1 t2 )
    call >r >r max r> r> min 2dup > [ drop dup ] when ; inline

: intersect-x ( gadget rect -- x1 x2 )
    [
        0 rectangle-x-extents >r swap 0 rectangle-x-extents r>
    ] intersect* ;

: intersect-y ( gadget rect -- y1 y2 )
    [
        0 rectangle-y-extents >r swap 0 rectangle-y-extents r>
    ] intersect* ;

: screen-bounds ( shape -- rect )
    [ shape-x x get + ] keep
    [ shape-y y get + ] keep
    [ shape-w ] keep
    shape-h
    <rectangle> ;

: clip-rect ( x1 x2 y1 y2 -- rect )
    over - 0 max >r >r over - 0 max r> swap r>
    <rectangle> ;

: intersect ( rect rect -- rect )
    [ intersect-x ] 2keep intersect-y clip-rect ;

: >sdl-rect ( rectangle -- sdlrect )
    [ rectangle-x ] keep
    [ rectangle-y ] keep
    [ rectangle-w ] keep
    rectangle-h
    make-rect ;

: set-clip ( rect -- ? )
    #! The top/left corner of the clip rectangle is the location
    #! of the gadget on the screen. The bottom/right is the
    #! intersected clip rectangle. Return t if the clip region
    #! is an empty region.
    surface get swap [ >sdl-rect SDL_SetClipRect drop ] keep
    dup shape-w 0 = swap shape-h 0 = or ;

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
    f over set-gadget-redraw?
    dup gadget-paint [
        dup [
            [
                drop
            ] [
                dup draw-shape dup [
                    gadget-children [ draw-gadget ] each
                ] with-trans
            ] ifte
        ] with-clip
    ] bind ;
