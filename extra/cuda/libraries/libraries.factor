! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.data alien.parser arrays
assocs combinators cuda cuda.ffi fry io.backend kernel macros
math namespaces sequences words ;
QUALIFIED-WITH: alien.c-types c
IN: cuda.libraries

SYMBOL: cuda-module
SYMBOL: cuda-function

SYMBOL: cuda-modules
SYMBOL: cuda-functions

SYMBOL: cuda-libraries
cuda-libraries [ H{ } clone ] initialize

SYMBOL: current-cuda-library

: ?delete-at ( key assoc -- old/key ? )
    2dup delete-at* [ 2nip t ] [ 2drop f ] if ; inline

: cuda-int* ( function offset value -- )
    cuParamSeti cuda-error ; inline

: cuda-int ( offset value -- )
    [ cuda-function get ] 2dip cuda-int* ; inline

: cuda-float* ( function offset value -- )
    cuParamSetf cuda-error ; inline

: cuda-float ( offset value -- )
    [ cuda-function get ] 2dip cuda-float* ; inline

: cuda-vector* ( function offset ptr n -- )
    cuParamSetv cuda-error ; inline

: cuda-vector ( offset ptr n -- )
    [ cuda-function get ] 3dip cuda-vector* ; inline

: param-size* ( function n -- )
    cuParamSetSize cuda-error ; inline

: param-size ( n -- )
    [ cuda-function get ] dip param-size* ; inline

: launch-function-grid* ( function width height -- )
    cuLaunchGrid cuda-error ; inline

: launch-function-grid ( width height -- )
    [ cuda-function get ] 2dip
    cuLaunchGrid cuda-error ; inline

: function-block-shape* ( function x y z -- )
    cuFuncSetBlockShape cuda-error ; inline

: function-block-shape ( x y z -- )
    [ cuda-function get ] 3dip
    cuFuncSetBlockShape cuda-error ; inline

: function-shared-size* ( function n -- )
    cuFuncSetSharedSize cuda-error ; inline

: function-shared-size ( n -- )
    [ cuda-function get ] dip
    cuFuncSetSharedSize cuda-error ; inline

TUPLE: function-launcher
dim-grid dim-block shared-size stream ;

: c-type>cuda-setter ( c-type -- n cuda-type )
    {
        { [ dup c:int = ] [ drop 4 [ cuda-int* ] ] }
        { [ dup c:uint = ] [ drop 4 [ cuda-int* ] ] }
        { [ dup c:float = ] [ drop 4 [ cuda-float* ] ] }
        { [ dup c:pointer? ] [ drop 4 [ cuda-int* ] ] }
        { [ dup c:void* = ] [ drop 4 [ cuda-int* ] ] }
    } cond ;

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

: launch-function* ( function -- ) cuLaunch cuda-error ; inline

: launch-function ( -- ) cuda-function get cuLaunch cuda-error ; inline

: run-function-launcher ( function-launcher function -- )
    swap
    {
        [ dim-block>> block-dim function-block-shape* ]
        [ shared-size>> function-shared-size* ]
        [
            dim-grid>>
            [ grid-dim launch-function-grid* ]
            [ launch-function* ] if*
        ]
    } 2cleave ;

: cuda-argument-setter ( offset c-type -- offset' quot )
    c-type>cuda-setter
    [ over [ + ] dip ] dip
    '[ swap _ swap _ call ] ;

MACRO: cuda-arguments ( c-types -- quot: ( args... function -- ) )
    [ 0 ] dip [ cuda-argument-setter ] map reverse
    swap '[ _ param-size* ] suffix
    '[ _ cleave ] ;

: get-function-ptr* ( module string -- function )
    [ CUfunction <c-object> ] 2dip
    [ cuModuleGetFunction cuda-error ] 3keep 2drop c:*void* ;

: get-function-ptr ( string -- function )
    [ cuda-module get ] dip get-function-ptr* ;

: cached-module ( module-name -- alien )
    lookup-cuda-library
    cuda-modules get-global [ load-cuda-library ] cache ;

: cached-function ( module-name function-name -- alien )
    [ cached-module ] dip
    2array cuda-functions get [ first2 get-function-ptr* ] cache ;

: define-cuda-word ( word module-name function-name arguments -- )
    [
        '[
            _ _ cached-function
            [ nip _ cuda-arguments ]
            [ run-function-launcher ] 2bi
        ]
    ]
    [ 2nip \ function-launcher suffix c:void function-effect ]
    3bi define-declared ;

TUPLE: cuda-library name path handle ;

: <cuda-library> ( name path -- obj )
    \ cuda-library new
        swap >>path
        swap >>name ;

: add-cuda-library ( name path -- )
    normalize-path <cuda-library>
    dup name>> cuda-libraries get-global set-at ;

