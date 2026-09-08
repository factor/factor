! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.c-types.varargs alien.libraries
alien.private arrays assocs combinators cpu.architecture effects generalizations kernel locals math math.order
namespaces quotations sequences sequences.generalizations stack-checker.backend
stack-checker.dependencies stack-checker.state
stack-checker.visitor strings system vocabs vocabs.loader words ;
FROM: kernel.private => CALLBACK-STUB declare special-object ;
QUALIFIED-WITH: alien.c-types c
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
        {
            [ parameters>> length ]
            [ alien-indirect-params? 1 0 ? ]
            [ dup alien-callback-params? [ varargs?>> 5 0 ? ] [ drop 0 ] if ]
        } cleave + +
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

ERROR: missing-varargs-count ;

ERROR: invalid-varargs-count count parameters ;

:: prepare-varargs ( params -- params )
    params varargs?>> :> count
    count t eq? os macos? cpu arm.64? and and
    [ missing-varargs-count ] when
    count integer? [
        count 0 params parameters>> length between? [
            params [ [| type i | type i count >= [ promote-vararg-type ] when ] map-index ] change-parameters
        ] [ count params parameters>> invalid-varargs-count ] if
    ] [ params ] if ;

: infer-alien-invoke ( -- )
    alien-invoke-params new
    ! Compile-time parameters
    pop-varargs?
    pop-params
    pop-function
    pop-library
    pop-return prepare-varargs
    ! Set ABI
    dup library>> library-abi >>abi
    ! Quotation which coerces parameters to required types
    dup param-prep-quot infer-quot-here
    ! Consume inputs and outputs and add node to IR
    dup dup inputs/outputs #alien-invoke,
    ! Quotation which coerces return value to required type
    infer-return ;

: (infer-alien-indirect) ( params -- )
    pop-abi pop-params pop-return prepare-varargs
    dup param-prep-quot '[ _ [ >c-ptr ] bi* ] infer-quot-here
    dup dup inputs/outputs #alien-indirect,
    infer-return ;

: infer-alien-indirect ( -- )
    alien-indirect-params new (infer-alien-indirect) ;

: infer-alien-indirect-varargs ( -- )
    alien-indirect-params new pop-varargs? (infer-alien-indirect) ;

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

ERROR: variadic-callback-runtime-required ;
ERROR: variadic-callback-architecture-unsupported ;

: check-variadic-callback-runtime ( -- )
    "arm64_variadic_callbacks_supported" f dlsym
    [ drop ] [ variadic-callback-runtime-required ] if*
    CALLBACK-STUB special-object length 3 <
    [ variadic-callback-runtime-required ] when ;

: callback-rewind ( word -- n )
    dup "callback-varargs" word-prop
    [ drop check-variadic-callback-runtime -1 ]
    [ "stack-cleanup" word-prop ] if ;

: callback-xt ( word -- alien )
    callbacks get [ dup callback-rewind <callback> ] cache ;

: callback-bottom ( params -- )
    "( callback )" <uninterned-word> >>xt
    dup [ xt>> ] [ varargs?>> ] bi "callback-varargs" set-word-prop
    xt>> '[ _ callback-xt { alien } declare ] infer-quot-here ;

: callback-return-quot ( ctype -- quot )
    return>> [ [ ] ] [ lookup-c-type c-type-unboxer-quot ] if-void ;

: named-callback-parameter-quot ( params -- quot )
    parameters>> [ lookup-c-type ] map
    [ [ c-type-class ] map '[ _ declare ] ]
    [ [ c-type-boxer-quot ] map deep-spread>quot ]
    bi append ;

! classes.struct loads the stack checker while its C type class is still
! being defined. The reader itself depends on that class, so load it only
! when compiling a callback that actually uses a variable argument list.
: va-reader-word ( name -- word )
    "alien.varargs" require "alien.varargs" lookup-word ;

: callback-parameter-quot ( params -- quot )
    [ named-callback-parameter-quot ] [ varargs?>> ] bi
    [ "<va-cursor>" va-reader-word '[ _ 5 ndip @ ] ] when ;

: native-va-list-parameter? ( type -- ? )
    "native-va-list-type?" "alien.varargs" lookup-word
    [ execute( type -- ? ) ] [ drop f ] if* ;

: callback-va-scope? ( params -- ? )
    [ varargs?>> ] [ parameters>> [ native-va-list-parameter? ] any? ] bi or ;

GENERIC: wrap-callback-quot ( params quot -- quot' )

SYMBOL: wait-for-callback-hook

wait-for-callback-hook [ [ drop ] ] initialize

M: callable wrap-callback-quot
    >quotation
    swap [ [ callback-parameter-quot ] [ callback-return-quot ] bi surround ]
    [ callback-va-scope? ] bi
    [ "with-va-scope" va-reader-word '[ _ @ ] ] when
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

:: (infer-alien-callback) ( varargs? -- )
    pop-literal :> quot
    alien-callback-params new varargs? >>varargs?
    pop-abi pop-params pop-return :> params
    varargs? cpu arm.64? not and
    [ variadic-callback-architecture-unsupported ] when
    params callback-bottom
    params dup dup quot wrap-callback-quot infer-callback-quot
    #alien-callback, ;

: infer-alien-callback ( -- ) f (infer-alien-callback) ;

: infer-alien-callback-varargs ( -- ) t (infer-alien-callback) ;
