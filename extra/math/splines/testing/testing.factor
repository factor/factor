! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays math.splines math.splines.viewer ;
IN: math.splines.testing

: test1 ( -- )
    {
        { { 0 0 } { 0 200 } }
        { { 100 50 } { 0 -200 } }
        { { 300 300 } { 500 200 } }
        { { 400 400 } { 300 0 } }
    } <cubic-hermite-spline> { 50 100 } 4 spline. ;

: test2 ( -- )
    {
        { 50 50 }
        { 100 100 }
        { 300 200 }
        { 350 0 }
        { 400 400 }
    } { 0 100 } { 100 0 } <catmull-rom-spline> { 100 50 } 50 spline. ;

:: test3 ( x y z -- )
    {
        { 100 50 }
        { 200 350 }
        { 300 50 }
    } { 0 100 } { 0 -100 } x y z <kochanek-bartels-curve> { 50 50 } 1000 spline. ;

: test4 ( -- )
    {
        { 0 5 }
        { 0.5 3 }
        { 10 10 }
        { 12 4 }
        { 15 5 }
    } <bezier-curve> 1array { 100 100 } 100 spline. ;

: test-splines ( -- )
    test1 test2
    1 0 0 test3
    -1 0 0 test3
    0 1 0 test3
    0 -1 0 test3
    0 0 1 test3
    0 0 -1 test3
    test4 ;
