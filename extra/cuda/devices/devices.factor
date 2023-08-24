! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings arrays
assocs byte-arrays combinators cuda cuda.contexts cuda.ffi
cuda.libraries io io.encodings.utf8 kernel math math.order
math.parser prettyprint sequences splitting ;
IN: cuda.devices

: #cuda-devices ( -- n )
    { int } [ cuDeviceGetCount cuda-error ] with-out-parameters ;

: n>cuda-device ( n -- device )
    [ { CUdevice } ] dip '[ _ cuDeviceGet cuda-error ] with-out-parameters ;

: enumerate-cuda-devices ( -- devices )
    #cuda-devices <iota> [ n>cuda-device ] map ;

: with-each-cuda-device ( quot -- )
    [ enumerate-cuda-devices ] dip '[ 0 _ with-cuda-context ] each ; inline

: cuda-device-properties ( n -- properties )
    [ CUdevprop new ] dip
    [ cuDeviceGetProperties cuda-error ] keepd ;

: cuda-devices ( -- assoc )
    enumerate-cuda-devices [ dup cuda-device-properties ] { } map>assoc ;

: cuda-device-name ( n -- string )
    [ 256 [ <byte-array> ] keep ] dip
    [ cuDeviceGetName cuda-error ]
    [ 2drop utf8 alien>string ] 3bi ;

: cuda-device-capability ( n -- pair )
    [ { int int } ] dip
    '[ _ cuDeviceComputeCapability cuda-error ] with-out-parameters
    2array ;

: cuda-device-memory ( n -- memory )
    [ 0 size_t <ref> ] dip [ cuDeviceTotalMem_v2 cuda-error ] keepd size_t deref ;

: cuda-device-attribute ( attribute n -- n )
    [ { int } ] 2dip
    '[ _ _ cuDeviceGetAttribute cuda-error ] with-out-parameters ;

: cuda-device. ( n -- )
    {
        [ "Device: " write number>string print ]
        [ "Name: " write cuda-device-name print ]
        [ "Memory: " write cuda-device-memory number>string print ]
        [
            "Capability: " write
            cuda-device-capability [ number>string ] map join-words print
        ]
        [ "Properties: " write cuda-device-properties . ]
        [
            "CU_DEVICE_ATTRIBUTE_GPU_OVERLAP: " write
            CU_DEVICE_ATTRIBUTE_GPU_OVERLAP swap
            cuda-device-attribute number>string print
        ]
    } cleave ;

: cuda-devices. ( -- )
    init-cuda
    enumerate-cuda-devices [ cuda-device. ] each ;

: cuda. ( -- )
    init-cuda
    "CUDA Version: " write cuda-version number>string print nl
    #cuda-devices <iota> [ nl ] [ cuda-device. ] interleave ;

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
