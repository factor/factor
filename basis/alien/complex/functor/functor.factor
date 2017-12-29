! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors2 ;
IN: alien.complex.functor

INLINE-FUNCTOR: complex-type ( N: existing-word T: name -- ) [[
    USING: alien alien.c-types classes.struct kernel quotations ;
    QUALIFIED: math

    <<
    STRUCT: ${T} { real ${N} } { imaginary ${N} } ;

    : <${T}> ( z -- alien )
        math:>rect ${T} <struct-boa> >c-ptr ;

    : *${T} ( alien -- z )
        ${T} memory>struct [ real>> ] [ imaginary>> ] bi math:rect> ; inline

    >>

    \ ${T} lookup-c-type
    [ <${T}> ] >>unboxer-quot
    [ *${T} ] >>boxer-quot
    complex >>boxed-class
    drop

]]
