! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.parser
alien.strings arrays assocs byte-arrays classes.struct
combinators continuations cuda.ffi destructors fry io
io.backend io.encodings.string io.encodings.utf8 kernel lexer
locals math math.parser namespaces opengl.gl.extensions
prettyprint quotations sequences ;
IN: cuda

SYMBOL: cuda-device
SYMBOL: cuda-context
SYMBOL: cuda-module
SYMBOL: cuda-function
SYMBOL: cuda-launcher
SYMBOL: cuda-memory-hashtable

ERROR: throw-cuda-error n ;

: cuda-error ( n -- )
    dup CUDA_SUCCESS = [ drop ] [ throw-cuda-error ] if ;

: cuda-version ( -- n )
    int <c-object> [ cuDriverGetVersion cuda-error ] keep *int ;

: init-cuda ( -- )
    0 cuInit cuda-error ;

TUPLE: launcher
{ device integer initial: 0 }
{ device-flags initial: 0 }
path block-shape shared-size grid ;

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

: with-cuda-program ( flags device path quot -- )
    [ dup cuda-device set ] 2dip
    '[
        cuda-context set
        _ [
            cuda-module set
            _ call
        ] with-cuda-module
    ] with-cuda-context ; inline

: with-cuda ( launcher quot -- )
    [
        init-cuda
        H{ } clone cuda-memory-hashtable
    ] 2dip '[
        _ 
        [ cuda-launcher set ]
        [ [ device>> ] [ device-flags>> ] [ path>> ] tri ] bi
        _ with-cuda-program
    ] with-variable ; inline

<PRIVATE

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

PRIVATE>

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

: get-cuda-function* ( module string -- function )
    [ CUfunction <c-object> ] 2dip
    [ cuModuleGetFunction cuda-error ] 3keep 2drop *void* ;

: get-cuda-function ( string -- function )
    [ cuda-module get ] dip get-cuda-function* ;

: with-cuda-function ( string quot -- )
    [
        get-cuda-function cuda-function set
    ] dip call ; inline

: launch-function* ( function -- ) cuLaunch cuda-error ;

: launch-function ( -- ) cuda-function get cuLaunch cuda-error ;

: launch-function-grid* ( function width height -- )
    cuLaunchGrid cuda-error ;

: launch-function-grid ( width height -- )
    [ cuda-function get ] 2dip
    cuLaunchGrid cuda-error ;

TUPLE: cuda-memory < disposable ptr length ;

: <cuda-memory> ( ptr length -- obj )
    cuda-memory new-disposable
        swap >>length
        swap >>ptr ;

: add-cuda-memory ( obj -- obj )
    dup dup ptr>> cuda-memory-hashtable get set-at ;

: delete-cuda-memory ( obj -- )
    cuda-memory-hashtable delete-at ;

ERROR: invalid-cuda-memory ptr ;

: cuda-memory-length ( cuda-memory -- n )
    ptr>> cuda-memory-hashtable get ?at [
        length>>
    ] [
        invalid-cuda-memory
    ] if ;

M: cuda-memory byte-length length>> ;

: cuda-malloc ( n -- ptr )
    [ CUdeviceptr <c-object> ] dip
    [ cuMemAlloc cuda-error ] 2keep
    [ *int ] dip <cuda-memory> add-cuda-memory ;

: cuda-free* ( ptr -- )
    cuMemFree cuda-error ;

M: cuda-memory dispose ( ptr -- )
    ptr>> cuda-free* ;

: host>device ( dest-ptr src-ptr -- )
    [ ptr>> ] dip dup length cuMemcpyHtoD cuda-error ;

:: device>host ( ptr -- seq )
    ptr byte-length <byte-array>
    [ ptr [ ptr>> ] [ byte-length ] bi cuMemcpyDtoH cuda-error ] keep ;

: memcpy-device>device ( dest-ptr src-ptr count -- )
    cuMemcpyDtoD cuda-error ;

: memcpy-device>array ( dest-array dest-index src-ptr count -- )
    cuMemcpyDtoA cuda-error ;

: memcpy-array>device ( dest-ptr src-array src-index count -- )
    cuMemcpyAtoD cuda-error ;

: memcpy-array>host ( dest-ptr src-array src-index count -- )
    cuMemcpyAtoH cuda-error ;

: memcpy-host>array ( dest-array dest-index src-ptr count -- )
    cuMemcpyHtoA cuda-error ;

: memcpy-array>array ( dest-array dest-index src-array src-ptr count -- )
    cuMemcpyAtoA cuda-error ;

: cuda-int* ( function offset value -- )
    cuParamSeti cuda-error ;

: cuda-int ( offset value -- )
    [ cuda-function get ] 2dip cuda-int* ;

: cuda-float* ( function offset value -- )
    cuParamSetf cuda-error ;

: cuda-float ( offset value -- )
    [ cuda-function get ] 2dip cuda-float* ;

: cuda-vector* ( function offset ptr n -- )
    cuParamSetv cuda-error ;

: cuda-vector ( offset ptr n -- )
    [ cuda-function get ] 3dip cuda-vector* ;

: param-size* ( function n -- )
    cuParamSetSize cuda-error ;

: param-size ( n -- )
    [ cuda-function get ] dip param-size* ;

: malloc-device-string ( string -- n )
    utf8 encode
    [ length cuda-malloc ] keep
    [ host>device ] [ drop ] 2bi ;

ERROR: bad-cuda-parameter parameter ;

:: set-parameters ( seq -- )
    cuda-function get :> function
    0 :> offset!
    seq [
        [ offset ] dip
        {
            { [ dup cuda-memory? ] [ ptr>> cuda-int ] }
            { [ dup float? ] [ cuda-float ] }
            { [ dup integer? ] [ cuda-int ] }
            [ bad-cuda-parameter ]
        } cond
        offset 4 + offset!
    ] each
    offset param-size ;

: cuda-device-attribute ( attribute dev -- n )
    [ int <c-object> ] 2dip
    [ cuDeviceGetAttribute cuda-error ]
    [ 2drop *int ] 3bi ;

: function-block-shape* ( function x y z -- )
    cuFuncSetBlockShape cuda-error ;

: function-block-shape ( x y z -- )
    [ cuda-function get ] 3dip
    cuFuncSetBlockShape cuda-error ;

: function-shared-size* ( function n -- )
    cuFuncSetSharedSize cuda-error ;

: function-shared-size ( n -- )
    [ cuda-function get ] dip
    cuFuncSetSharedSize cuda-error ;

: launch ( -- )
    cuda-launcher get {
        [ block-shape>> first3 function-block-shape ]
        [ shared-size>> function-shared-size ]
        [
            grid>> [
                launch-function
            ] [
                first2 launch-function-grid
            ] if-empty
        ]
    } cleave ;

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


: test-cuda0 ( -- )
    T{ launcher
        { path "vocab:cuda/hello.ptx" }
        { block-shape { 6 6 6 } }
        { shared-size 2 }
        { grid { 2 6 } }
    } [
        "helloWorld" [
            "Hello World!" [ - ] map-index
            malloc-device-string &dispose

            [ 1array set-parameters ]
            [ drop launch ]
            [ device>host utf8 alien>string . ] tri
        ] with-cuda-function
    ] with-cuda ;
