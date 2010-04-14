! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data assocs classes.struct
combinators continuations cuda.ffi fry io.backend kernel
sequences ;
IN: cuda

ERROR: throw-cuda-error n ;

: cuda-error ( n -- )
    {
        { CUDA_SUCCESS [ ] }
        [ throw-cuda-error ]
    } case ;

: cuda-version ( -- n )
    int <c-object> [ cuDriverGetVersion cuda-error ] keep *int ;

: init-cuda ( -- )
    0 cuInit cuda-error ;

: with-cuda ( quot -- )
    init-cuda [ ] [ ] cleanup ; inline

<PRIVATE

: #cuda-devices ( -- n )
    int <c-object> [ cuDeviceGetCount cuda-error ] keep *int ;

: n>cuda-device ( n -- device )
    [ CUdevice <c-object> ] dip [ cuDeviceGet cuda-error ] 2keep drop *int ;

: enumerate-cuda-devices ( -- devices )
    #cuda-devices iota [ n>cuda-device ] map ;

: cuda-device>properties ( device -- properties )
    [ CUdevprop <c-object> ] dip
    [ cuDeviceGetProperties cuda-error ] 2keep drop
    CUdevprop memory>struct ;

: cuda-device-properties ( -- properties )
    enumerate-cuda-devices [ cuda-device>properties ] map ;

PRIVATE>

: cuda-devices ( -- assoc )
    enumerate-cuda-devices [ dup cuda-device>properties ] { } map>assoc ;

: with-cuda-context ( flags device quot -- )
    [
        [ CUcontext <c-object> ] 2dip
        [ cuCtxCreate cuda-error ] 3keep 2drop *void*
    ] dip 
    [ '[ _ @ ] ]
    [ drop '[ _ cuCtxDestroy cuda-error ] ] 2bi
    [ ] cleanup ; inline

: with-cuda-module ( path quot -- )
    [
        normalize-path
        [ CUmodule <c-object> ] dip
        [ cuModuleLoad cuda-error ] 2keep drop *void*
    ] dip
    [ '[ _ @ ] ]
    [ drop '[ _ cuModuleUnload cuda-error ] ] 2bi
    [ ] cleanup ; inline

: get-cuda-function ( module string -- function )
    [ CUfunction <c-object> ] 2dip
    [ cuModuleGetFunction cuda-error ] 3keep 2drop *void* ;

: cuda-malloc ( n -- ptr )
    [ CUdeviceptr <c-object> ] dip
    [ cuMemAlloc cuda-error ] 2keep drop *int ;

: cuda-free ( ptr -- )
    cuMemFree cuda-error ;
