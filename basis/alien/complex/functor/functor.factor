! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors2 ;
IN: alien.complex.functor

FUNCTOR: define-complex-type ( N: name T: name -- ) [[

STRUCT: ${T}-class { real ${N}-type } { imaginary ${N}-type } ;

: <${T}> ( z -- alien )
    >rect ${T}-class <struct-boa> >c-ptr ;

: *${T} ( alien -- z )
    T-class memory>struct [ real>> ] [ imaginary>> ] bi rect> ; inline

${T}-class lookup-c-type
<${T}> 1quotation >>unboxer-quot
*${T} 1quotation >>boxer-quot
complex >>boxed-class
drop

]]