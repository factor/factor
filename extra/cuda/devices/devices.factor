! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data alien.strings arrays assocs
byte-arrays classes.struct combinators cuda.ffi cuda.utils io
io.encodings.utf8 kernel math.parser prettyprint sequences ;
IN: cuda.devices

: #cuda-devices ( -- n )
    int <c-object> [ cuDeviceGetCount cuda-error ] keep *int ;

: n>cuda-device ( n -- device )
    [ CUdevice <c-object> ] dip [ cuDeviceGet cuda-error ] 2keep drop *int ;

: enumerate-cuda-devices ( -- devices )
    #cuda-devices iota [ n>cuda-device ] map ;

: cuda-device-properties ( device -- properties )
    [ CUdevprop <c-object> ] dip
    [ cuDeviceGetProperties cuda-error ] 2keep drop
    CUdevprop memory>struct ;

: cuda-devices ( -- assoc )
    enumerate-cuda-devices [ dup cuda-device-properties ] { } map>assoc ;

: cuda-device-name ( n -- string )
    [ 256 [ <byte-array> ] keep ] dip
    [ cuDeviceGetName cuda-error ]
    [ 2drop utf8 alien>string ] 3bi ;

: cuda-device-capability ( n -- pair )
    [ int <c-object> int <c-object> ] dip
    [ cuDeviceComputeCapability cuda-error ]
    [ drop [ *int ] bi@ ] 3bi 2array ;

: cuda-device-memory ( n -- bytes )
    [ uint <c-object> ] dip
    [ cuDeviceTotalMem cuda-error ]
    [ drop *uint ] 2bi ;

: cuda-device-attribute ( attribute dev -- n )
    [ int <c-object> ] 2dip
    [ cuDeviceGetAttribute cuda-error ]
    [ 2drop *int ] 3bi ;

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
    "CUDA Version: " write cuda-version number>string print nl
    #cuda-devices iota [ nl ] [ cuda-device. ] interleave ;

