! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl sdl-gfx ;

! The painting protocol. Painting is controlled by various
! dynamically-scoped variables.

! "Paint" is a namespace containing some or all of these values.
SYMBOL: color ! a list of three integers, 0..255.
SYMBOL: font  ! a list of two elements, a font name and size.

: shape>screen ( shape -- x1 y1 x2 y2 )
    [ shape-x x get + ] keep
    [ shape-y y get + ] keep
    [ dup shape-x swap shape-w + x get + ] keep
    dup shape-y swap shape-h + y get + ;

: rgb-color ( -- rgba ) color get 3unlist rgb ;

GENERIC: draw-shape ( obj -- )

M: rectangle draw-shape drop ;

M: point draw-shape ( point -- )
    >r surface get r> dup point-x swap point-y
    rgb-color pixelColor ;

TUPLE: hollow-rect delegate ;

C: hollow-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-hollow-rect-delegate ] keep ;

M: hollow-rect draw-shape ( rect -- )
    >r surface get r> shape>screen rgb-color rectangleColor ;

TUPLE: plain-rect delegate ;

C: plain-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-plain-rect-delegate ] keep ;

M: plain-rect draw-shape ( rect -- )
    >r surface get r> shape>screen rgb-color boxColor ;

: x1/x2/y1 ( #{ x1 y1 }# #{ x2 y2 }# -- x1 x2 y1 )
    >r >rect r> real swap ;

: x1/x2/y2 ( #{ x1 y1 }# #{ x2 y2 }# -- x1 x2 y2 )
    >r real r> >rect ;

: x1/y1/y2 ( #{ x1 y1 }# #{ x2 y2 }# -- x1 y1 y2 )
    >r >rect r> imaginary ;

: x2/y1/y2 ( #{ x1 y1 }# #{ x2 y2 }# -- x2 y1 y2 )
    >r imaginary r> >rect >r swap r> ;

: (draw-bevel) ( #{ x1 y1 }# #{ x2 y2 }# -- )
    surface get pick pick x1/x2/y1 240 240 240 rgb hlineColor
    surface get pick pick x1/x2/y2 192 192 192 rgb hlineColor
    surface get pick pick x1/y1/y2 240 240 240 rgb vlineColor
    surface get pick pick x2/y1/y2 192 192 192 rgb vlineColor
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

: default-paint ( -- paint )
    {{
        [[ x 0 ]]
        [[ y 0 ]]
        [[ color [ 160 160 160 ] ]]
        [[ font [[ "Monospaced" 12 ]] ]]
    }} ;
