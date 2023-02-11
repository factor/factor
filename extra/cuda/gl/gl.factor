! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.destructors
alien.enums continuations cuda cuda.contexts cuda.ffi
cuda.gl.ffi destructors gpu.buffers kernel ;
IN: cuda.gl

: create-gl-cuda-context ( device flags -- context )
    swap
    [ { CUcontext } ] 2dip
    '[ _ _ cuGLCtxCreate cuda-error ] with-out-parameters ; inline

: with-gl-cuda-context ( device flags quot -- )
    [ set-up-cuda-context create-gl-cuda-context ] dip (with-cuda-context) ; inline

: gl-buffer>resource ( gl-buffer flags -- resource )
    enum>number
    [ { CUgraphicsResource } ] 2dip
    '[ _ _ cuGraphicsGLRegisterBuffer cuda-error ] with-out-parameters ; inline

: buffer>resource ( buffer flags -- resource )
    [ handle>> ] dip gl-buffer>resource ; inline

: map-resource ( resource -- device-ptr size )
    [ 1 swap void* <ref> f cuGraphicsMapResources cuda-error ] [
        [ { CUdeviceptr uint } ] dip
        '[ _ cuGraphicsResourceGetMappedPointer cuda-error ]
        with-out-parameters
    ] bi ; inline

: unmap-resource ( resource -- )
    1 swap void* <ref> f cuGraphicsUnmapResources cuda-error ; inline

DESTRUCTOR: unmap-resource

: free-resource ( resource -- )
    cuGraphicsUnregisterResource cuda-error ; inline

DESTRUCTOR: free-resource

: with-mapped-resource ( ..a resource quot: ( ..a device-ptr size -- ..b ) -- ..b )
    over [ map-resource ] 2dip '[ _ unmap-resource ] finally ; inline

TUPLE: cuda-buffer
    { buffer buffer }
    { resource pinned-c-ptr } ;

: <cuda-buffer> ( upload usage kind size initial-data flags -- buffer )
    [ <buffer> dup ] dip buffer>resource cuda-buffer boa ; inline

M: cuda-buffer dispose
    [ [ free-resource ] when* f ] change-resource
    buffer>> dispose ; inline

: with-mapped-cuda-buffer ( ..a cuda-buffer quot: ( ..a device-ptr size -- ..b ) -- ..b )
    [ resource>> ] dip with-mapped-resource ; inline
