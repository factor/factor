! :folding=indent:collapseFolds=1:sidekick.parser=none:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: sdl-gfx
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
