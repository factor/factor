! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.complex classes.struct math
namespaces tools.test ;
IN: alien.complex.tests

STRUCT: complex-holder
    { z complex-float } ;

: <complex-holder> ( z -- alien )
    complex-holder <struct-boa> ;

{ } [
    C{ 1.0 2.0 } <complex-holder> "h" set
] unit-test

{ C{ 1.0 2.0 } } [ "h" get z>> ] unit-test

{ complex } [ complex-float c-type-boxed-class ] unit-test

{ complex } [ complex-double c-type-boxed-class ] unit-test
