! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors combinators math namespaces
init sets words assocs alien.libraries alien alien.c-types
cpu.architecture fry stack-checker.backend stack-checker.errors
stack-checker.visitor stack-checker.dependencies ;
IN: stack-checker.alien

TUPLE: alien-node-params return parameters abi in-d out-d ;

TUPLE: alien-invoke-params < alien-node-params library function ;

TUPLE: alien-indirect-params < alien-node-params ;

TUPLE: alien-assembly-params < alien-node-params quot ;

TUPLE: alien-callback-params < alien-node-params quot xt ;

: param-prep-quot ( params -- quot )
    parameters>> [ c-type c-type-unboxer-quot ] map spread>quot ;

: infer-params ( params -- )
    param-prep-quot infer-quot-here ;

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
    dup infer-params
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
    ! Quotation which coerces parameters to required types
    1 infer->r
    dup infer-params
    1 infer-r>
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
    dup infer-params
    ! Magic #: consume exactly the number of inputs
    dup 0 alien-stack
    ! Add node to IR
    dup #alien-assembly,
    ! Quotation which coerces return value to required type
    infer-return ;

: callback-xt ( word return-rewind -- alien )
    [ callbacks get ] dip '[ _ <callback> ] cache ;

: callback-bottom ( params -- )
    [ xt>> ] [ callback-return-rewind ] bi
    '[ _ _ callback-xt ] infer-quot-here ;

: infer-alien-callback ( -- )
    alien-callback-params new
    pop-quot
    pop-abi
    pop-params
    pop-return
    "( callback )" <uninterned-word> >>xt
    dup callback-bottom
    #alien-callback, ;
