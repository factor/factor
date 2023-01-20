! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data alien.parser arrays assocs
byte-arrays classes.struct classes.struct.private combinators
combinators.short-circuit cuda cuda.ffi fry generalizations
io.backend kernel locals macros math namespaces sequences
variants vocabs.loader words ;
QUALIFIED-WITH: alien.c-types c
IN: cuda.libraries

VARIANT: cuda-abi
    cuda32 cuda64 ;

SYMBOL: cuda-modules
SYMBOL: cuda-functions

SYMBOL: cuda-libraries
cuda-libraries [ H{ } clone ] initialize

SYMBOL: current-cuda-library

: cuda-param-size ( function n -- )
    cuParamSetSize cuda-error ; inline

: cuda-vector ( function offset ptr n -- )
    cuParamSetv cuda-error ; inline

: launch-function-grid ( function width height -- )
    cuLaunchGrid cuda-error ; inline

: function-block-shape ( function x y z -- )
    cuFuncSetBlockShape cuda-error ; inline

: function-shared-size ( function n -- )
    cuFuncSetSharedSize cuda-error ; inline

TUPLE: grid
    { dim-grid read-only }
    { dim-block read-only }
    { shared-size read-only initial: 0 }
    { stream read-only } ;

: <grid> ( dim-grid dim-block -- grid )
    0 f grid boa ; inline

: <grid-shared> ( dim-grid dim-block shared-size -- grid )
    f grid boa ; inline

: <grid-shared-stream> ( dim-grid dim-block shared-size stream -- grid )
    grid boa ; inline

<PRIVATE
GENERIC: block-dim ( block-size -- x y z ) foldable
M: integer block-dim 1 1 ; inline
M: sequence block-dim
    dup length {
        { 0 [ drop 1 1 1 ] }
        { 1 [ first 1 1 ] }
        { 2 [ first2 1 ] }
        [ drop first3 ]
    } case ; inline

GENERIC: grid-dim ( grid-size -- x y ) foldable
M: integer grid-dim 1 ; inline
M: sequence grid-dim
    dup length {
        { 0 [ drop 1 1 ] }
        { 1 [ first 1 ] }
        [ drop first2 ]
    } case ; inline
PRIVATE>

: load-module ( path -- module )
    [ { CUmodule } ] dip
    '[ _ cuModuleLoad cuda-error ] with-out-parameters ;

: unload-module ( module -- )
    cuModuleUnload cuda-error ;

: load-cuda-library ( library -- handle )
    path>> load-module ;

ERROR: no-cuda-library name ;

: lookup-cuda-library ( name -- cuda-library )
    cuda-libraries get ?at [ no-cuda-library ] unless ;

: remove-cuda-library ( name -- library )
    cuda-libraries get ?delete-at [ no-cuda-library ] unless ;

: unload-cuda-library ( name -- )
    remove-cuda-library handle>> unload-module ;

: launch-function ( function -- ) cuLaunch cuda-error ; inline

: run-grid ( grid function -- )
    swap
    {
        [ dim-block>> block-dim function-block-shape ]
        [ shared-size>> function-shared-size ]
        [
            dim-grid>>
            [ grid-dim launch-function-grid ]
            [ launch-function ] if*
        ]
    } 2cleave ; inline

<PRIVATE
: make-param-buffer ( function size -- buffer size )
    [ cuda-param-size ] [ (byte-array) ] [ ] tri ; inline

: fill-param-buffer ( values... buffer quots... n -- )
    [ cleave-curry ] [ spread* ] bi ; inline

: pointer-argument-type? ( c-type -- ? )
    { [ c:void* = ] [ CUdeviceptr = ] [ c:pointer? ] } 1|| ;

: abi-pointer-type ( abi -- type )
    {
        { cuda32 [ c:uint ] }
        { cuda64 [ CUulonglong ] }
    } case ;

: >argument-type ( c-type abi -- c-type' )
    swap {
        { [ dup pointer-argument-type? ] [ drop abi-pointer-type ] }
        { [ dup c:double    = ] [ 2drop CUdouble ] }
        { [ dup c:longlong  = ] [ 2drop CUlonglong ] }
        { [ dup c:ulonglong = ] [ 2drop CUulonglong ] }
        [ nip ]
    } cond ;

: >argument-struct-slot ( c-type abi -- slot )
    >argument-type "cuda-arg" swap { } <struct-slot-spec> ;

: [cuda-arguments] ( c-types abi -- quot )
    '[ _ >argument-struct-slot ] map
    [ compute-struct-offsets ]
    [ [ '[ _ write-struct-slot ] ] [ ] map-as ]
    [ length ] tri
    '[
        [ _ make-param-buffer [ drop @ _ fill-param-buffer ] 2keep ]
        [ '[ _ 0 ] 2dip cuda-vector ] bi
    ] ;
PRIVATE>

MACRO: cuda-arguments ( c-types abi -- quot: ( args... function -- ) )
    [ [ 0 cuda-param-size ] ] swap '[ _ [cuda-arguments] ] if-empty ;

: get-function-ptr ( module string -- function )
    [ { CUfunction } ] 2dip
    '[ _ _ cuModuleGetFunction cuda-error ] with-out-parameters ;

: cached-module ( module-name -- alien )
    lookup-cuda-library
    cuda-modules get-global [ load-cuda-library ] cache ;

: cached-function ( module-name function-name -- alien )
    [ cached-module ] dip
    2array cuda-functions get [ first2 get-function-ptr ] cache ;

MACRO: cuda-invoke ( module-name function-name arguments -- quot )
    pick lookup-cuda-library abi>> '[
        _ _ cached-function
        [ nip _ _ cuda-arguments ]
        [ run-grid ] 2bi
    ] ;

: cuda-global* ( module-name symbol-name -- device-ptr size )
    [ { CUdeviceptr { c:uint initial: 0 } } ] 2dip
    [ cached-module ] dip
    '[ _ _ cuModuleGetGlobal cuda-error ] with-out-parameters ; inline

: cuda-global ( module-name symbol-name -- device-ptr )
    cuda-global* drop ; inline

:: define-cuda-function ( word module-name function-name types names -- )
    word
    [ module-name function-name types cuda-invoke ]
    names "grid" suffix c:void function-effect
    define-inline ;

: define-cuda-global ( word module-name symbol-name -- )
    '[ _ _ cuda-global ] ( -- device-ptr ) define-inline ;

TUPLE: cuda-library name abi path handle ;
ERROR: bad-cuda-abi abi ;

: check-cuda-abi ( abi -- abi )
    dup cuda-abi? [ bad-cuda-abi ] unless ; inline

: <cuda-library> ( name abi path -- obj )
    \ cuda-library new
        swap >>path
        swap check-cuda-abi >>abi
        swap >>name ; inline

: add-cuda-library ( name abi path -- )
    normalize-path <cuda-library>
    dup name>> cuda-libraries get-global set-at ;

{ "cuda.libraries" "prettyprint" } "cuda.prettyprint" require-when
