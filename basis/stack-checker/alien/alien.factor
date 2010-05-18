! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays sequences accessors combinators math
namespaces init sets words assocs alien.libraries alien
alien.private alien.c-types fry quotations strings
stack-checker.backend stack-checker.errors stack-checker.visitor
stack-checker.dependencies compiler.utilities ;
IN: stack-checker.alien

TUPLE: alien-node-params
return parameters
{ abi abi initial: cdecl }
in-d
out-d ;

TUPLE: alien-invoke-params < alien-node-params library { function string } ;

TUPLE: alien-indirect-params < alien-node-params ;

TUPLE: alien-assembly-params < alien-node-params { quot quotation } ;

TUPLE: alien-callback-params < alien-node-params { quot quotation } xt ;

: param-prep-quot ( params -- quot )
    parameters>> [ c-type c-type-unboxer-quot ] map spread>quot ;

: alien-stack ( params extra -- )
    over parameters>> length + consume-d >>in-d
    dup return>> void? 0 1 ? produce-d >>out-d
    drop ;

: return-prep-quot ( params -- quot )
    return>> [ [ ] ] [ c-type c-type-boxer-quot ] if-void ;

: infer-return ( params -- )
    return-prep-quot infer-quot-here ;

: pop-return ( params -- params )
    pop-literal [ depends-on-c-type ] [ nip >>return ] bi ;

: pop-library ( params -- params )
    pop-literal nip >>library ;

: pop-function ( params -- params )
    pop-literal nip >>function ;

: pop-params ( params -- params )
    pop-literal [ [ depends-on-c-type ] each ] [ nip >>parameters ] bi ;

: pop-abi ( params -- params )
    pop-literal nip >>abi ;

: pop-quot ( params -- params )
    pop-literal nip >>quot ;

: infer-alien-invoke ( -- )
    alien-invoke-params new
    ! Compile-time parameters
    pop-params
    pop-function
    pop-library
    pop-return
    ! Set ABI
    dup library>> library-abi >>abi
    ! Quotation which coerces parameters to required types
    dup param-prep-quot infer-quot-here
    ! Magic #: consume exactly the number of inputs
    dup 0 alien-stack
    ! Add node to IR
    dup #alien-invoke,
    ! Quotation which coerces return value to required type
    infer-return ;

: infer-alien-indirect ( -- )
    alien-indirect-params new
    ! Compile-time parameters
    pop-abi
    pop-params
    pop-return
    ! Coerce parameters to required types
    dup param-prep-quot '[ _ [ >c-ptr ] bi* ] infer-quot-here
    ! Magic #: consume the function pointer, too
    dup 1 alien-stack
    ! Add node to IR
    dup #alien-indirect,
    ! Quotation which coerces return value to required type
    infer-return ;

: infer-alien-assembly ( -- )
    alien-assembly-params new
    ! Compile-time parameters
    pop-quot
    pop-abi
    pop-params
    pop-return
    ! Quotation which coerces parameters to required types
    dup param-prep-quot infer-quot-here
    ! Magic #: consume exactly the number of inputs
    dup 0 alien-stack
    ! Add node to IR
    dup #alien-assembly,
    ! Quotation which coerces return value to required type
    infer-return ;

: callback-xt ( word -- alien )
    callbacks get [ dup "stack-cleanup" word-prop <callback> ] cache ;

: callback-bottom ( params -- )
    xt>> '[ _ callback-xt ] infer-quot-here ;

: callback-return-quot ( ctype -- quot )
    return>> [ [ ] ] [ c-type c-type-unboxer-quot ] if-void ;

: callback-prep-quot ( params -- quot )
    parameters>> [ c-type c-type-boxer-quot ] map spread>quot ;

: wrap-callback-quot ( params -- quot )
    [ callback-prep-quot ] [ quot>> ] [ callback-return-quot ] tri 3append
     yield-hook get
     '[ _ _ do-callback ]
     >quotation ;

: infer-alien-callback ( -- )
    alien-callback-params new
    pop-quot
    pop-abi
    pop-params
    pop-return
    "( callback )" <uninterned-word> >>xt
    dup wrap-callback-quot >>quot
    dup callback-bottom
    #alien-callback, ;
