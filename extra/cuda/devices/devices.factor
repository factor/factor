! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings arrays
assocs byte-arrays classes.struct combinators cuda
cuda.contexts cuda.ffi cuda.libraries fry io io.encodings.utf8
kernel locals math math.order math.parser namespaces
prettyprint sequences ;
IN: cuda.devices

: #cuda-devices ( -- n )
    int <c-object> [ cuDeviceGetCount cuda-error ] keep int deref ;

: n>cuda-device ( n -- device )
    [ CUdevice <c-object> ] dip [ cuDeviceGet cuda-error ] 2keep
    drop int deref ;

: enumerate-cuda-devices ( -- devices )
    #cuda-devices iota [ n>cuda-device ] map ;

: with-each-cuda-device ( quot -- )
    [ enumerate-cuda-devices ] dip '[ 0 _ with-cuda-context ] each ; inline

: cuda-device-properties ( n -- properties )
    [ CUdevprop <struct> ] dip
    [ cuDeviceGetProperties cuda-error ] 2keep drop ;

: cuda-devices ( -- assoc )
    enumerate-cuda-devices [ dup cuda-device-properties ] { } map>assoc ;

: cuda-device-name ( n -- string )
    [ 256 [ <byte-array> ] keep ] dip
    [ cuDeviceGetName cuda-error ]
    [ 2drop utf8 alien>string ] 3bi ;

: cuda-device-capability ( n -- pair )
    [ int <c-object> int <c-object> ] dip
    [ cuDeviceComputeCapability cuda-error ]
    [ drop [ int deref ] bi@ ] 3bi 2array ;

: cuda-device-memory ( n -- bytes )
    [ uint <c-object> ] dip
    [ cuDeviceTotalMem cuda-error ]
    [ drop uint deref ] 2bi ;

: cuda-device-attribute ( attribute n -- n )
    [ int <c-object> ] 2dip
    [ cuDeviceGetAttribute cuda-error ]
    [ 2drop int deref ] 3bi ;

: cuda-device. ( n -- )
    {
        [ "Device: " write number>string print ]
        [ "Name: " write cuda-device-name print ]
        [ "Memory: " write cuda-device-memory number>string print ]
        [
            "Capability: " write
            cuda-device-capability [ number>string ] map " " join print
        ]
        [ "Properties: " write cuda-device-properties . ]
        [
            "CU_DEVICE_ATTRIBUTE_GPU_OVERLAP: " write
            CU_DEVICE_ATTRIBUTE_GPU_OVERLAP swap
            cuda-device-attribute number>string print
        ]
    } cleave ;

: cuda. ( -- )
    init-cuda
    "CUDA Version: " write cuda-version number>string print nl
    #cuda-devices iota [ nl ] [ cuda-device. ] interleave ;

: up/i ( x y -- z )
    [ 1 - + ] keep /i ; inline

: context-device-properties ( -- props )
    context-device cuda-device-properties ; inline

:: (distribute-jobs) ( job-count per-job-shared max-shared-size max-block-size
                       -- grid-size block-size per-block-shared )
    per-job-shared [ max-block-size ] [ max-shared-size swap /i max-block-size min ] if-zero
        job-count min :> job-max-block-size
    job-count job-max-block-size up/i :> grid-size
    job-count grid-size up/i          :> block-size
    block-size per-job-shared *       :> per-block-shared

    grid-size block-size per-block-shared ; inline

: distribute-jobs ( job-count per-job-shared -- launcher )
    context-device-properties
    [ sharedMemPerBlock>> ] [ maxThreadsPerBlock>> ] bi
    (distribute-jobs) <grid-shared> ; inline
