! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math namespaces sdl
sdl-gfx sdl-ttf sdl-video strings ;

! The painting protocol. Painting is controlled by various
! dynamically-scoped variables.

! "Paint" is a namespace containing some or all of these values.

: paint-property ( gadget key -- value )
    swap gadget-paint hash ;

: set-paint-property ( gadget value key -- )
    rot gadget-paint set-hash ;

! Colors are lists of three integers, 0..255.
SYMBOL: foreground ! Used for text and outline shapes.
SYMBOL: background ! Used for filled shapes.
SYMBOL: reverse-video

: fg reverse-video get background foreground ? get ;
: bg reverse-video get foreground background ? get ;

SYMBOL: font  ! a list of two elements, a font name and size.

GENERIC: draw-shape ( obj -- )

! Actual rectangles don't draw; use a hollow-rect, plain-rect
! or bevel-rect instead.
M: rectangle draw-shape drop ;

TUPLE: hollow-rect delegate ;

C: hollow-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-hollow-rect-delegate ] keep ;

M: hollow-rect draw-shape ( rect -- )
    >r surface get r> rect>screen fg rgb rectangleColor ;

TUPLE: plain-rect delegate ;

C: plain-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-plain-rect-delegate ] keep ;

M: plain-rect draw-shape ( rect -- )
    >r surface get r> rect>screen bg rgb boxColor ;

TUPLE: etched-rect delegate ;

C: etched-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-etched-rect-delegate ] keep ;

M: etched-rect draw-shape ( rect -- )
    >r surface get r> 2dup
    rect>screen bg rgb boxColor
    rect>screen fg rgb rectangleColor ;

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

! Strings are shapes too. This is somewhat of a hack and strings
! do not have x/y co-ordinates.
M: string shape-x drop 0 ;
M: string shape-y drop 0 ;
M: string shape-w
    font get swap size-string ( h -) drop ;

M: string shape-h ( text -- h )
    #! This is just the height of the current font.
    drop font get lookup-font TTF_FontHeight ;

M: string draw-shape ( text -- )
    >r x get y get font get r>
    fg 3unlist make-color
    draw-string drop ;

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
    [ shape-w 1 + ] keep
    shape-h 1 +
    <rectangle> ;

: clip-rect ( x1 x2 y1 y2 -- rect )
    over - 0 max >r >r over - 0 max r> swap r>
    <rectangle> ;

: intersect ( rect rect -- rect )
    [ intersect-x ] 2keep intersect-y clip-rect ;

: set-clip ( rect -- ? )
    #! The top/left corner of the clip rectangle is the location
    #! of the gadget on the screen. The bottom/right is the
    #! intersected clip rectangle. Return t if the clip region
    #! is an empty region.
    surface get swap [ >sdl-rect SDL_SetClipRect drop ] keep
    dup shape-w 0 = swap shape-h 0 = or ;

GENERIC: shape-clip ( shape -- clip )
M: object shape-clip
    #! By default, we clip to the bounds of the shape. However,
    #! the hand disables clipping for its children.
    screen-bounds ;

: with-clip ( shape quot -- )
    #! All drawing done inside the quotation is clipped to the
    #! shape's bounds. The quotation is called with a boolean
    #! that is set to false if 
    [
        >r shape-clip clip [ intersect dup ] change set-clip r>
        call
    ] with-scope ; inline

: >sdl-rect ( rectangle -- sdlrect )
    [ rectangle-x ] keep
    [ rectangle-y ] keep
    [ rectangle-w ] keep
    rectangle-h
    make-rect ;

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
