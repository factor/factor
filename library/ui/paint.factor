! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl sdl-gfx ;

! The painting protocol. Painting is controlled by various
! dynamically-scoped variables.

! "Paint" is a namespace containing some or all of these values.
SYMBOL: color  ! a list of three integers, 0..255.
SYMBOL: font   ! a list of two elements, a font name and size.
SYMBOL: filled ! is the interior of the shape filled?

: shape>screen ( shape -- x1 y1 x2 y2 )
    [ shape-x x get + ] keep
    [ shape-y y get + ] keep
    [ dup shape-x swap shape-w + x get + ] keep
    dup shape-y swap shape-h + y get + ;

: rgb-color ( -- rgba ) color get 3unlist rgb ;

GENERIC: draw ( obj -- )

M: number draw ( point -- )
    >r surface get r> >rect rgb-color pixelColor ;

M: rectangle draw ( rect -- )
    >r surface get r> shape>screen rgb-color
    filled get [ boxColor ] [ rectangleColor ] ifte ;

: default-paint ( -- paint )
    {{
        [[ x 0 ]]
        [[ y 0 ]]
        [[ color [ 0 0 0 ] ]]
        [[ filled f ]]
        [[ font [[ "Monospaced" 12 ]] ]]
    }} ;
