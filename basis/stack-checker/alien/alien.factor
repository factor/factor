! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.libraries
alien.private arrays assocs combinators effects fry kernel math
namespaces quotations sequences stack-checker.backend
stack-checker.dependencies stack-checker.state
stack-checker.visitor strings words ;
FROM: kernel.private => declare ;
IN: stack-checker.alien

TUPLE: alien-node-params
    return parameters
    { abi abi initial: cdecl } varargs? ;

TUPLE: alien-invoke-params < alien-node-params
    library
    { function string } ;

TUPLE: alien-indirect-params < alien-node-params ;

TUPLE: alien-assembly-params < alien-node-params
    { quot callable } ;

TUPLE: alien-callback-params < alien-node-params
    xt ;

: param-prep-quot ( params -- quot )
    parameters>> [ lookup-c-type c-type-unboxer-quot ] map deep-spread>quot ;

: stack-shape ( params -- in out )
    [
        [ parameters>> length ] [ alien-indirect-params? 1 0 ? ] bi +
    ] [ return>> void? 0 1 ? ] bi ;

: inputs/outputs ( params -- in-d out-d )
    stack-shape [ consume-d ] [ produce-d ] bi* ;

: return-prep-quot ( params -- quot )
    return>> [ [ ] ] [ lookup-c-type c-type-boxer-quot ] if-void ;

: infer-return ( params -- )
    return-prep-quot infer-quot-here ;

: pop-abi ( params -- params )
    pop-literal >>abi ;

: pop-function ( params -- params )
    pop-literal >>function ;

: pop-library ( params -- params )
    pop-literal >>library ;

: pop-params ( params -- params )
    pop-literal [ [ add-depends-on-c-type ] each ] [ >>parameters ] bi ;

: pop-quot ( params -- params )
    pop-literal >>quot ;

: pop-return ( params -- params )
    pop-literal [ add-depends-on-c-type ] [ >>return ] bi ;

: pop-varargs? ( params -- params )
    pop-literal >>varargs? ;

: infer-alien-invoke ( -- )
    alien-invoke-params new
    ! Compile-time parameters
    pop-varargs?
    pop-params
    pop-function
    pop-library
    pop-return
    ! Set ABI
    dup library>> library-abi >>abi
    ! Quotation which coerces parameters to required types
    dup param-prep-quot infer-quot-here
    ! Consume inputs and outputs and add node to IR
    dup dup inputs/outputs #alien-invoke,
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
    ! Consume inputs and outputs and add node to IR
    dup dup inputs/outputs #alien-indirect,
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
    ! Consume inputs and outputs and add node to IR
    dup dup inputs/outputs #alien-assembly,
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
    stack-shape [ "x" <array> ] bi@ <effect> ;

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
    pop-literal [
        alien-callback-params new
        pop-abi
        pop-params
        pop-return
        dup callback-bottom
        dup
        dup
    ] dip wrap-callback-quot infer-callback-quot
    #alien-callback, ;
