! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.structs alien.c-types math math.functions sequences
arrays kernel functors vocabs.parser namespaces accessors
quotations ;
IN: alien.complex.functor

FUNCTOR: define-complex-type ( N T -- )

T-real DEFINES ${T}-real
T-imaginary DEFINES ${T}-imaginary
set-T-real DEFINES set-${T}-real
set-T-imaginary DEFINES set-${T}-imaginary

<T> DEFINES <${T}>
*T DEFINES *${T}

WHERE

: <T> ( z -- alien )
    >rect T <c-object> [ set-T-imaginary ] [ set-T-real ] [ ] tri ; inline

: *T ( alien -- z )
    [ T-real ] [ T-imaginary ] bi rect> ; inline

T current-vocab
{ { N "real" } { N "imaginary" } }
define-struct

T c-type
<T> 1quotation >>unboxer-quot
*T 1quotation >>boxer-quot
drop

;FUNCTOR
