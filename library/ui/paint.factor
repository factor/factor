! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl sdl-gfx ;

! The painting protocol. Painting is controlled by various
! dynamically-scoped variables.

! "Paint" is a namespace containing some or all of these values.

! Colors are lists of three integers, 0..255.
SYMBOL: foreground ! Used for text and outline shapes.
SYMBOL: background ! Used for filled shapes.
SYMBOL: bevel-1
SYMBOL: bevel-2
SYMBOL: bevel-up?

SYMBOL: font  ! a list of two elements, a font name and size.

: shape>screen ( shape -- x1 y1 x2 y2 )
    [ shape-x x get + ] keep
    [ shape-y y get + ] keep
    [ dup shape-x swap shape-w + x get + ] keep
    dup shape-y swap shape-h + y get + ;

GENERIC: draw-shape ( obj -- )

M: rectangle draw-shape drop ;

M: point draw-shape ( point -- )
    >r surface get r> dup point-x swap point-y
    foreground get rgb pixelColor ;

TUPLE: hollow-rect delegate ;

C: hollow-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-hollow-rect-delegate ] keep ;

M: hollow-rect draw-shape ( rect -- )
    >r surface get r> shape>screen foreground get rgb
    rectangleColor ;

TUPLE: plain-rect delegate ;

C: plain-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-plain-rect-delegate ] keep ;

M: plain-rect draw-shape ( rect -- )
    >r surface get r> shape>screen background get rgb
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
    shape>screen >r >r rect> r> r> rect> 3 draw-bevel ;

: draw-gadget ( gadget -- )
    #! All drawing done inside draw-shape is done with the
    #! gadget's paint. If the gadget does not have any custom
    #! paint, just call the quotation.
    dup gadget-paint [
        dup draw-shape
        dup [
            gadget-children [ draw-gadget ] each
        ] with-translation
    ] bind ;
