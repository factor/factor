! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.structs alien.structs.fields alien.c-types
math math.functions sequences arrays kernel functors
vocabs.parser namespaces accessors quotations ;
IN: alien.complex.functor

TUPLE: complex-c-type < struct-type
    array-class
    array-constructor
    direct-array-class
    direct-array-constructor
    sequence-mixin-class ;
INSTANCE: complex-c-type array-c-type

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

T  N c-type-align [ 2 * ] [ ] bi
T current-vocab N "real" <field-spec>
T current-vocab N "imaginary" <field-spec> N c-type-align >>offset
2array complex-c-type (define-struct)

T c-type
<T> 1quotation >>unboxer-quot
*T 1quotation >>boxer-quot
number >>boxed-class
T set-array-class
drop

;FUNCTOR
