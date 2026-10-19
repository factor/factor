IN: alien.c-types.capabilities
! Struct definitions load the stack checker, which references this API.
DEFER: floating-point-types-supported?
DEFER: floating-point-foreign-call-unsupported
DEFER: check-floating-point-types
USING: accessors alien.arrays alien.c-types arrays cpu.architecture
kernel math sequences ;
IN: alien.c-types.capabilities

ERROR: floating-point-foreign-call-unsupported signature ;

GENERIC: contains-floating-point? ( c-type -- ? )
M: c-type contains-floating-point?
    c-type-rep { float-rep double-rep } member? ;
M: vector-c-type contains-floating-point?
    c-type-rep scalar-rep-of { float-rep double-rep } member? ;
M: small-float-c-type contains-floating-point? drop t ;
M: string-type contains-floating-point? drop f ;
M: array contains-floating-point? first lookup-c-type contains-floating-point? ;
M: object contains-floating-point? drop f ;

: floating-point-types-supported? ( types -- ? )
    floating-point-supported? [ drop t ] [
        [ dup void? [ drop f ] [ base-type contains-floating-point? ] if ] any? not
    ] if ;

: check-floating-point-types ( signature types -- )
    floating-point-types-supported?
    [ drop ] [ floating-point-foreign-call-unsupported ] if ;
