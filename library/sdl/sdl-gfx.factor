! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sdl USING: alien ;

: pixelColor ( surface x y color -- )
    "void" "sdl-gfx" "pixelColor"
    [ "surface*" "short" "short" "uint" ]
    alien-invoke ;

: hlineColor ( surface x1 x2 y color -- )
    "void" "sdl-gfx" "hlineColor"
    [ "surface*" "short" "short" "short" "uint" ]
    alien-invoke ;

: vlineColor ( surface x y1 y2 color -- )
    "void" "sdl-gfx" "vlineColor"
    [ "surface*" "short" "short" "short" "uint" ]
    alien-invoke ;

: rectangleColor ( surface x1 y1 x2 y2 color -- )
    "void" "sdl-gfx" "rectangleColor"
    [ "surface*" "short" "short" "short" "short" "uint" ]
    alien-invoke ;

: boxColor ( surface x1 y1 x2 y2 color -- )
    "void" "sdl-gfx" "boxColor"
    [ "surface*" "short" "short" "short" "short" "uint" ]
    alien-invoke ;

: lineColor ( surface x1 y1 x2 y2 color -- )
    "void" "sdl-gfx" "lineColor"
    [ "surface*" "short" "short" "short" "short" "uint" ]
    alien-invoke ;

: aalineColor ( surface x1 y1 x2 y2 color -- )
    "void" "sdl-gfx" "aalineColor"
    [ "surface*" "short" "short" "short" "short" "uint" ]
    alien-invoke ;

: circleColor ( surface x y r color -- )
    "void" "sdl-gfx" "circleColor"
    [ "surface*" "short" "short" "short" "uint" ]
    alien-invoke ;

: aacircleColor ( surface x y r color -- )
    "void" "sdl-gfx" "aacircleColor"
    [ "surface*" "short" "short" "short" "uint" ]
    alien-invoke ;

: filledCircleColor ( surface x y r color -- )
    "void" "sdl-gfx" "filledCircleColor"
    [ "surface*" "short" "short" "short" "uint" ]
    alien-invoke ;

: ellipseColor ( surface x y rx ry color -- )
    "void" "sdl-gfx" "ellipseColor"
    [ "surface*" "short" "short" "short" "short" "uint" ]
    alien-invoke ;

: aaellipseColor ( surface x y rx ry color -- )
    "void" "sdl-gfx" "aaellipseColor"
    [ "surface*" "short" "short" "short" "short" "uint" ]
    alien-invoke ;

: filledEllipseColor ( surface x y rx ry color -- )
    "void" "sdl-gfx" "filledEllipseColor"
    [ "surface*" "short" "short" "short" "short" "uint" ]
    alien-invoke ;

: pieColor ( surface x y rad start end color -- )
    "void" "sdl-gfx" "pieColor"
    [ "surface*" "short" "short" "short" "short" "short" "uint" ]
    alien-invoke ;

: filledPieColor ( surface x y rad start end color -- )
    "void" "sdl-gfx" "filledPieColor"
    [ "surface*" "short" "short" "short" "short" "short" "uint" ]
    alien-invoke ;

: trigonColor ( surface x1 y1 x2 y2 x3 y3 color -- )
    "void" "sdl-gfx" "trigonColor"
    [ "surface*" "short" "short" "short" "short" "short" "short" "uint" ]
    alien-invoke ;

: aatrigonColor ( surface x1 y1 x2 y2 x3 y3 color -- )
    "void" "sdl-gfx" "aatrigonColor"
    [ "surface*" "short" "short" "short" "short" "short" "short" "uint" ]
    alien-invoke ;

: filledTrigonColor ( surface x1 y1 x2 y2 x3 y3 color -- )
    "void" "sdl-gfx" "filledTrigonColor"
    [ "surface*" "short" "short" "short" "short" "short" "short" "uint" ]
    alien-invoke ;

: characterColor ( surface x y c color -- )
    "void" "sdl-gfx" "characterColor"
    [ "surface*" "short" "short" "char" "uint" ]
    alien-invoke ;

: stringColor ( surface x y str color -- )
    "void" "sdl-gfx" "stringColor"
    [ "surface*" "short" "short" "char*" "uint" ]
    alien-invoke ;
