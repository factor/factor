IN: sdl
USE: alien

: pixelColor ( surface x y color -- )
    "void" "sdl-gfx" "pixelColor"
    [ "surface*" "short" "short" "uint" ]
    alien-call ;

: hlineColor ( surface x1 x2 y color -- )
    "void" "sdl-gfx" "hlineColor"
    [ "surface*" "short" "short" "short" "uint" ]
    alien-call ;

: vlineColor ( surface x y1 y2 color -- )
    "void" "sdl-gfx" "vlineColor"
    [ "surface*" "short" "short" "short" "uint" ]
    alien-call ;

: rectangleColor ( surface x1 y1 x2 y2 color -- )
    "void" "sdl-gfx" "rectangleColor"
    [ "surface*" "short" "short" "short" "short" "uint" ]
    alien-call ;

: boxColor ( surface x1 y1 x2 y2 color -- )
    "void" "sdl-gfx" "boxColor"
    [ "surface*" "short" "short" "short" "short" "uint" ]
    alien-call ;

: lineColor ( surface x1 y1 x2 y2 color -- )
    "void" "sdl-gfx" "lineColor"
    [ "surface*" "short" "short" "short" "short" "uint" ]
    alien-call ;

: aalineColor ( surface x1 y1 x2 y2 color -- )
    "void" "sdl-gfx" "aalineColor"
    [ "surface*" "short" "short" "short" "short" "uint" ]
    alien-call ;

: circleColor ( surface x y r color -- )
    "void" "sdl-gfx" "circleColor"
    [ "surface*" "short" "short" "short" "uint" ]
    alien-call ;

: aacircleColor ( surface x y r color -- )
    "void" "sdl-gfx" "aacircleColor"
    [ "surface*" "short" "short" "short" "uint" ]
    alien-call ;

: filledCircleColor ( surface x y r color -- )
    "void" "sdl-gfx" "filledCircleColor"
    [ "surface*" "short" "short" "short" "uint" ]
    alien-call ;

: ellipseColor ( surface x y rx ry color -- )
    "void" "sdl-gfx" "ellipseColor"
    [ "surface*" "short" "short" "short" "short" "uint" ]
    alien-call ;

: aaellipseColor ( surface x y rx ry color -- )
    "void" "sdl-gfx" "aaellipseColor"
    [ "surface*" "short" "short" "short" "short" "uint" ]
    alien-call ;

: filledEllipseColor ( surface x y rx ry color -- )
    "void" "sdl-gfx" "filledEllipseColor"
    [ "surface*" "short" "short" "short" "short" "uint" ]
    alien-call ;

: pieColor ( surface x y rad start end color -- )
    "void" "sdl-gfx" "pieColor"
    [ "surface*" "short" "short" "short" "short" "short" "uint" ]
    alien-call ;

: filledPieColor ( surface x y rad start end color -- )
    "void" "sdl-gfx" "filledPieColor"
    [ "surface*" "short" "short" "short" "short" "short" "uint" ]
    alien-call ;

: trigonColor ( surface x1 y1 x2 y2 x3 y3 color -- )
    "void" "sdl-gfx" "trigonColor"
    [ "surface*" "short" "short" "short" "short" "short" "short" "uint" ]
    alien-call ;

: aatrigonColor ( surface x1 y1 x2 y2 x3 y3 color -- )
    "void" "sdl-gfx" "aatrigonColor"
    [ "surface*" "short" "short" "short" "short" "short" "short" "uint" ]
    alien-call ;

: filledTrigonColor ( surface x1 y1 x2 y2 x3 y3 color -- )
    "void" "sdl-gfx" "filledTrigonColor"
    [ "surface*" "short" "short" "short" "short" "short" "short" "uint" ]
    alien-call ;

: characterColor ( surface x y c color -- )
    "void" "sdl-gfx" "characterColor"
    [ "surface*" "short" "short" "char" "uint" ]
    alien-call ;

: stringColor ( surface x y str color -- )
    "void" "sdl-gfx" "stringColor"
    [ "surface*" "short" "short" "char*" "uint" ]
    alien-call ;
