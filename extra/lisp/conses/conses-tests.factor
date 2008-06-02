! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test lisp.conses math ;

IN: lisp.conses.tests

{ { 3 4 5 6 } } [
    T{ cons f 1       
        T{ cons f 2 
            T{ cons f 3
                T{ cons f 4
                T{ cons f f f } } } } } [ 2 + ] map-cons
] unit-test