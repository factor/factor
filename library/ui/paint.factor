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
SYMBOL: bevel-1
SYMBOL: bevel-2
SYMBOL: bevel-up?

SYMBOL: font  ! a list of two elements, a font name and size.

GENERIC: draw-shape ( obj -- )

! Actual rectangles don't draw; use a hollow-rect, plain-rect
! or bevel-rect instead.
M: rectangle draw-shape drop ;

TUPLE: hollow-rect delegate ;

C: hollow-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-hollow-rect-delegate ] keep ;

M: hollow-rect draw-shape ( rect -- )
    >r surface get r> rect>screen foreground get rgb
    rectangleColor ;

TUPLE: plain-rect delegate ;

C: plain-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-plain-rect-delegate ] keep ;

M: plain-rect draw-shape ( rect -- )
    >r surface get r> rect>screen background get rgb
     boxColor ;

: x1/x2/y1 ( #{ x1 y1 }# #{ x2 y2 }# -- x1 x2 y1 )
    >r >rect r> real swap ;

: x1/x2/y2 ( #{ x1 y1 }# #{ x2 y2 }# -- x1 x2 y2 )
    >r real r> >rect ;

: x1/y1/y2 ( #{ x1 y1 }# #{ x2 y2 }# -- x1 y1 y2 )
    >r >rect r> imaginary ;

: x2/y1/y2 ( #{ x1 y1 }# #{ x2 y2 }# -- x2 y1 y2 )
    >r imaginary r> >rect >r swap r> ;

: bevel-up ( -- rgb )
    bevel-up? get [ bevel-1 get ] [ bevel-2 get ] ifte rgb ;

: bevel-down ( -- rgb )
    bevel-up? get [ bevel-2 get ] [ bevel-1 get ] ifte rgb ;

: (draw-bevel) ( #{ x1 y1 }# #{ x2 y2 }# -- )
    surface get pick pick x1/x2/y1 bevel-up   hlineColor
    surface get pick pick x1/x2/y2 bevel-down hlineColor
    surface get pick pick x1/y1/y2 bevel-up   vlineColor
    surface get pick pick x2/y1/y2 bevel-down vlineColor
    2drop ;

TUPLE: bevel-rect delegate bevel ;

C: bevel-rect ( bevel x y w h -- rect )
    [ >r <rectangle> r> set-bevel-rect-delegate ] keep
    [ set-bevel-rect-bevel ] keep ;

: draw-bevel ( #{ x1 y1 }# #{ x2 y2 }# n -- )
    [
        pick over #{ 1 1 }# * +
        pick pick #{ 1 1 }# * -
        (draw-bevel)
    ] repeat 2drop ;

M: bevel-rect draw-shape ( rect -- )
    rect>screen >r >r rect> r> r> rect> 3 draw-bevel ;

M: line draw-shape ( line -- )
    >r surface get r>
    line>screen
    foreground get rgb
    lineColor ;

M: ellipse draw-shape drop ;

TUPLE: hollow-ellipse delegate ;

C: hollow-ellipse ( x y w h -- ellipse )
    [ >r <ellipse> r> set-hollow-ellipse-delegate ] keep ;

M: hollow-ellipse draw-shape ( ellipse -- )
    >r surface get r> ellipse>screen foreground get rgb
    ellipseColor ;

TUPLE: plain-ellipse delegate ;

C: plain-ellipse ( x y w h -- ellipse )
    [ >r <ellipse> r> set-plain-ellipse-delegate ] keep ;

M: plain-ellipse draw-shape ( ellipse -- )
    >r surface get r> ellipse>screen background get rgb
    filledEllipseColor ;

: set-clip ( -- )
    surface get x get y get width get height get make-rect
    SDL_SetClipRect drop ;

: draw-gadget ( gadget -- )
    #! All drawing done inside draw-shape is done with the
    #! gadget's paint. If the gadget does not have any custom
    #! paint, just call the quotation.
    dup gadget-paint [
        dup [
            set-clip
            dup draw-shape
            dup [
                gadget-children [ draw-gadget ] each
            ] with-trans
        ] with-clip
    ] bind ;

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
    foreground get 3unlist make-color
    draw-string drop ;
