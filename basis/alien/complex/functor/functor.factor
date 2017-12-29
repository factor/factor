! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors2 ;
IN: alien.complex.functor

INLINE-FUNCTOR: complex-type ( n: existing-word t: name -- ) [[
    USING: alien alien.c-types classes.struct kernel quotations ;
    QUALIFIED: math

    <<
    STRUCT: ${t} { real ${n} } { imaginary ${n} } ;

    : <${t}> ( z -- alien )
        math:>rect ${t} <struct-boa> >c-ptr ;

    : *${t} ( alien -- z )
        ${t} memory>struct [ real>> ] [ imaginary>> ] bi math:rect> ; inline

    >>

    \ ${t} lookup-c-type
    [ <${t}> ] >>unboxer-quot
    [ *${t} ] >>boxer-quot
    complex >>boxed-class
    drop

]]
