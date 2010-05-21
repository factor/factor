! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.data alien.parser arrays assocs
byte-arrays classes.struct combinators combinators.short-circuit
cuda cuda.ffi fry generalizations io.backend kernel macros math
namespaces sequences words ;
FROM: classes.struct.private => compute-struct-offsets write-struct-slot ;
QUALIFIED-WITH: alien.c-types c
IN: cuda.libraries

SYMBOL: cuda-modules
SYMBOL: cuda-functions

SYMBOL: cuda-libraries
cuda-libraries [ H{ } clone ] initialize

SYMBOL: current-cuda-library

: ?delete-at ( key assoc -- old/key ? )
    2dup delete-at* [ 2nip t ] [ 2drop f ] if ; inline

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
dim-grid dim-block shared-size stream ;

: <grid> ( dim-grid dim-block -- grid )
    0 f grid boa ; inline

: <grid-shared> ( dim-grid dim-block shared-size -- grid )
    f grid boa ; inline

: <grid-shared-stream> ( dim-grid dim-block shared-size stream -- grid )
    grid boa ; inline

<PRIVATE
: block-dim ( block -- x y z )
    dup sequence? [ 3 1 pad-tail first3 ] [ 1 1 ] if ; inline
: grid-dim ( block -- x y )
    dup sequence? [ 2 1 pad-tail first2 ] [ 1 ] if ; inline
PRIVATE>

: load-module ( path -- module )
    [ CUmodule <c-object> ] dip
    [ cuModuleLoad cuda-error ] 2keep drop c:*void* ;

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
    } 2cleave ;

<PRIVATE
: make-param-buffer ( function size -- buffer size )
    [ cuda-param-size ] [ (byte-array) ] [ ] tri ; inline

: fill-param-buffer ( values... buffer quots... n -- )
    [ cleave-curry ] [ spread* ] bi ; inline

: >argument-type ( c-type -- c-type' )
    dup { [ c:void* = ] [ c:pointer? ] } 1|| [ drop CUdeviceptr ] when ;

: >argument-struct-slot ( type -- slot )
    "cuda-arg" swap >argument-type { } <struct-slot-spec> ;

: [cuda-arguments] ( c-types -- quot )
    [ >argument-struct-slot ] map
    [ compute-struct-offsets ]
    [ [ '[ _ write-struct-slot ] ] [ ] map-as ]
    [ length ] tri
    '[
        [ _ make-param-buffer [ drop @ _ fill-param-buffer ] 2keep ]
        [ '[ _ 0 ] 2dip cuda-vector ] bi
    ] ;
PRIVATE>

MACRO: cuda-arguments ( c-types -- quot: ( args... function -- ) )
    [ [ 0 cuda-param-size ] ] [ [cuda-arguments] ] if-empty ;

: get-function-ptr ( module string -- function )
    [ CUfunction <c-object> ] 2dip
    [ cuModuleGetFunction cuda-error ] 3keep 2drop c:*void* ;

: cached-module ( module-name -- alien )
    lookup-cuda-library
    cuda-modules get-global [ load-cuda-library ] cache ;

: cached-function ( module-name function-name -- alien )
    [ cached-module ] dip
    2array cuda-functions get [ first2 get-function-ptr ] cache ;

MACRO: cuda-invoke ( module-name function-name arguments -- )
    '[
        _ _ cached-function
        [ nip _ cuda-arguments ]
        [ run-grid ] 2bi
    ] ;

: cuda-global* ( module-name symbol-name -- device-ptr size )
    [ CUdeviceptr <c-object> c:uint <c-object> ] 2dip
    [ cached-module ] dip 
    '[ _ _ cuModuleGetGlobal cuda-error ] 2keep [ c:*uint ] bi@ ; inline

: cuda-global ( module-name symbol-name -- device-ptr )
    cuda-global* drop ; inline

: define-cuda-function ( word module-name function-name arguments -- )
    [ '[ _ _ _ cuda-invoke ] ]
    [ 2nip \ grid suffix c:void function-effect ]
    3bi define-declared ;

: define-cuda-global ( word module-name symbol-name -- )
    '[ _ _ cuda-global ] (( -- device-ptr )) define-declared ;

TUPLE: cuda-library name path handle ;

: <cuda-library> ( name path -- obj )
    \ cuda-library new
        swap >>path
        swap >>name ;

: add-cuda-library ( name path -- )
    normalize-path <cuda-library>
    dup name>> cuda-libraries get-global set-at ;

