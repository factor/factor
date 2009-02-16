! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test alien.complex kernel alien.c-types alien.syntax
namespaces ;
IN: alien.complex.tests

C-STRUCT: complex-holder
    { "complex-float" "z" } ;

: <complex-holder> ( z -- alien )
    "complex-holder" <c-object>
    [ set-complex-holder-z ] keep ;

[ ] [
    C{ 1.0 2.0 } <complex-holder> "h" set
] unit-test

[ C{ 1.0 2.0 } ] [ "h" get complex-holder-z ] unit-test
