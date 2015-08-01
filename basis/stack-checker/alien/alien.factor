! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.libraries
alien.private arrays assocs combinators effects fry kernel math
namespaces quotations sequences stack-checker.backend
stack-checker.dependencies stack-checker.state
stack-checker.visitor strings words ;
FROM: kernel.private => declare ;
IN: stack-checker.alien

TUPLE: alien-node-params
return parameters
{ abi abi initial: cdecl }
in-d
out-d ;

TUPLE: alien-invoke-params < alien-node-params library { function string } ;

TUPLE: alien-indirect-params < alien-node-params ;

TUPLE: alien-assembly-params < alien-node-params { quot callable } ;

TUPLE: alien-callback-params < alien-node-params xt ;

: param-prep-quot ( params -- quot )
    parameters>> [ lookup-c-type c-type-unboxer-quot ] map deep-spread>quot ;

: alien-stack ( params extra -- )
    over parameters>> length + consume-d >>in-d
    dup return>> void? 0 1 ? produce-d >>out-d
    drop ;

: return-prep-quot ( params -- quot )
    return>> [ [ ] ] [ lookup-c-type c-type-boxer-quot ] if-void ;

: infer-return ( params -- )
    return-prep-quot infer-quot-here ;

: pop-return ( params -- params )
    pop-literal [ add-depends-on-c-type ] [ nip >>return ] bi ;

: pop-library ( params -- params )
    pop-literal nip >>library ;

: pop-function ( params -- params )
    pop-literal nip >>function ;

: pop-params ( params -- params )
    pop-literal [ [ add-depends-on-c-type ] each ] [ nip >>parameters ] bi ;

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
    "( callback )" <uninterned-word> >>xt
    xt>> '[ _ callback-xt { alien } declare ] infer-quot-here ;

: callback-return-quot ( ctype -- quot )
    return>> [ [ ] ] [ lookup-c-type c-type-unboxer-quot ] if-void ;

: callback-parameter-quot ( params -- quot )
    parameters>> [ lookup-c-type ] map
    [ [ c-type-class ] map '[ _ declare ] ]
    [ [ c-type-boxer-quot ] map deep-spread>quot ]
    bi append ;

GENERIC: wrap-callback-quot ( params quot -- quot' )

SYMBOL: wait-for-callback-hook

wait-for-callback-hook [ [ drop ] ] initialize

M: callable wrap-callback-quot
    swap [ callback-parameter-quot ] [ callback-return-quot ] bi surround
    wait-for-callback-hook get
    '[ _ _ do-callback ] >quotation ;

: callback-effect ( params -- effect )
    [ parameters>> length "x" <array> ]
    [ return>> void? { } { "x" } ? ] bi <effect> ;

: infer-callback-quot ( params quot -- child )
    [
        init-inference
        nest-visitor
        infer-quot-here
        end-infer
        callback-effect check-effect
        stack-visitor get
    ] with-scope ;

: infer-alien-callback ( -- )
    pop-literal nip [
        alien-callback-params new
        pop-abi
        pop-params
        pop-return
        dup callback-bottom
        dup
        dup
    ] dip wrap-callback-quot infer-callback-quot
    #alien-callback, ;
