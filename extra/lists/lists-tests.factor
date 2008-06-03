! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test lists math ;

IN: lists.tests

{ { 3 4 5 6 } } [
    T{ cons f 1       
        T{ cons f 2 
            T{ cons f 3
                T{ cons f 4
                T{ cons f f f } } } } } [ 2 + ] map-cons
] unit-test

{ 10 } [
 T{ cons f 1       
        T{ cons f 2 
            T{ cons f 3
                T{ cons f 4
                T{ cons f f f } } } } } 0 [ + ] reduce-cons
] unit-test