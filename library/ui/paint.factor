! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math namespaces sdl
stdio strings ;

! The painting protocol. Painting is controlled by various
! dynamically-scoped variables.

! "Paint" is a namespace containing some or all of these values.

: paint-prop ( gadget key -- value )
    swap gadget-paint hash ;

: set-paint-prop ( gadget value key -- )
    rot gadget-paint set-hash ;

! Colors are lists of three integers, 0..255.
SYMBOL: foreground ! Used for text and outline shapes.
SYMBOL: background ! Used for filled shapes.
SYMBOL: reverse-video

: fg reverse-video get background foreground ? get ;
: bg reverse-video get foreground background ? get ;

SYMBOL: font  ! a list of two elements, a font name and size.

GENERIC: draw-shape ( obj -- )

M: rectangle draw-shape drop ;

! A rectangle only whose outline is visible.
TUPLE: hollow-rect delegate ;

C: hollow-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-hollow-rect-delegate ] keep ;

: hollow-rect ( shape -- )
    #! Draw a hollow rect with the bounds of an arbitrary shape.
    rect>screen >r 1 - r> 1 - fg rgb rectangleColor ;

M: hollow-rect draw-shape ( rect -- )
    >r surface get r> hollow-rect ;

! A rectangle that is filled.
TUPLE: plain-rect delegate ;

C: plain-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-plain-rect-delegate ] keep ;

: plain-rect ( shape -- )
    #! Draw a filled rect with the bounds of an arbitrary shape.
    rect>screen bg rgb boxColor ;

M: plain-rect draw-shape ( rect -- )
    >r surface get r> plain-rect ;

! A rectangle that is filled, and has a visible outline.
TUPLE: etched-rect delegate ;

C: etched-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-etched-rect-delegate ] keep ;

M: etched-rect draw-shape ( rect -- )
    >r surface get r> 2dup plain-rect hollow-rect ;

! A rectangle that has a visible outline only if the rollover
! paint property is set.
SYMBOL: rollover?

TUPLE: roll-rect delegate ;

C: roll-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-roll-rect-delegate ] keep ;

M: roll-rect draw-shape ( rect -- )
    >r surface get r> 2dup
    plain-rect rollover? get [ hollow-rect ] [ 2drop ] ifte ;

M: line draw-shape ( line -- )
    >r surface get r>
    line>screen
    fg rgb
    aalineColor ;

M: ellipse draw-shape drop ;

TUPLE: hollow-ellipse delegate ;

C: hollow-ellipse ( x y w h -- ellipse )
    [ >r <ellipse> r> set-hollow-ellipse-delegate ] keep ;

M: hollow-ellipse draw-shape ( ellipse -- )
    >r surface get r> ellipse>screen fg rgb
    ellipseColor ;

TUPLE: plain-ellipse delegate ;

C: plain-ellipse ( x y w h -- ellipse )
    [ >r <ellipse> r> set-plain-ellipse-delegate ] keep ;

M: plain-ellipse draw-shape ( ellipse -- )
    >r surface get r> ellipse>screen bg rgb
    filledEllipseColor ;

! Clipping

SYMBOL: clip

: intersect* ( gadget rect quot -- t1 t2 )
    call >r >r max r> r> min 2dup > [ drop dup ] when ;

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
    #! that is set to false if 
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
                drop
            ] [
                dup draw-shape dup [
                    gadget-children [ draw-gadget ] each
                ] with-trans
            ] ifte
        ] with-clip
    ] bind ;
