! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors combinators math namespaces
init sets words assocs alien.libraries alien alien.c-types
stack-checker.backend stack-checker.errors stack-checker.visitor ;
IN: stack-checker.alien

TUPLE: alien-node-params return parameters abi in-d out-d ;

TUPLE: alien-invoke-params < alien-node-params library function ;

TUPLE: alien-indirect-params < alien-node-params ;

TUPLE: alien-callback-params < alien-node-params quot xt ;

: param-prep-quot ( node -- quot )
    parameters>> [ c-type c-type-unboxer-quot ] map spread>quot ;

: alien-stack ( params extra -- )
    over parameters>> length + consume-d >>in-d
    dup return>> void? 0 1 ? produce-d >>out-d
    drop ;

: return-prep-quot ( node -- quot )
    return>> [ [ ] ] [ c-type c-type-boxer-quot ] if-void ;

: infer-alien-invoke ( -- )
    alien-invoke-params new
    ! Compile-time parameters
    pop-literal nip >>parameters
    pop-literal nip >>function
    pop-literal nip >>library
    pop-literal nip >>return
    ! Quotation which coerces parameters to required types
    dup param-prep-quot infer-quot-here
    ! Set ABI
    dup library>> library [ abi>> ] [ "cdecl" ] if* >>abi
    ! Magic #: consume exactly the number of inputs
    dup 0 alien-stack
    ! Add node to IR
    dup #alien-invoke,
    ! Quotation which coerces return value to required type
    return-prep-quot infer-quot-here ;

: infer-alien-indirect ( -- )
    alien-indirect-params new
    ! Compile-time parameters
    pop-literal nip >>abi
    pop-literal nip >>parameters
    pop-literal nip >>return
    ! Quotation which coerces parameters to required types
    dup param-prep-quot [ dip ] curry infer-quot-here
    ! Magic #: consume the function pointer, too
    dup 1 alien-stack
    ! Add node to IR
    dup #alien-indirect,
    ! Quotation which coerces return value to required type
    return-prep-quot infer-quot-here ;

: callback-xt ( word -- alien )
    callbacks get [ <callback> ] cache ;

: callback-bottom ( params -- )
    xt>> [ callback-xt ] curry infer-quot-here ;

: infer-alien-callback ( -- )
    alien-callback-params new
    pop-literal nip >>quot
    pop-literal nip >>abi
    pop-literal nip >>parameters
    pop-literal nip >>return
    "( callback )" f <word> >>xt
    dup callback-bottom
    #alien-callback, ;
