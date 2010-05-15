! (c)2010 Joe Groff bsd license
USING: accessors alien.c-types alien.data alien.destructors
alien.enums continuations cuda cuda.ffi cuda.gl.ffi cuda.utils
destructors fry gpu.buffers kernel ;
IN: cuda.gl

: create-gl-cuda-context ( device flags -- context )
    swap
    [ CUcontext <c-object> ] 2dip
    [ cuGLCtxCreate cuda-error ] 3keep 2drop *void* ; inline

: with-gl-cuda-context ( device flags quot -- )
    [ [ create-gl-cuda-context ] (set-up-cuda-context) ] dip (with-cuda-context) ; inline 

: gl-buffer>resource ( gl-buffer flags -- resource )
    enum>number
    [ CUgraphicsResource <c-object> ] 2dip
    [ cuGraphicsGLRegisterBuffer cuda-error ] 3keep 2drop *void* ; inline

: buffer>resource ( buffer flags -- resource )
    [ handle>> ] dip gl-buffer>resource ; inline

: map-resource ( resource -- device-ptr size )
    [ 1 swap <void*> f cuGraphicsMapResources cuda-error ] [
        [ CUdeviceptr <c-object> uint <c-object> ] dip
        [ cuGraphicsResourceGetMappedPointer cuda-error ] 3keep drop
        [ *uint ] [ *uint ] bi*
    ] bi ; inline

: unmap-resource ( resource -- )
    1 swap <void*> f cuGraphicsUnmapResources cuda-error ; inline

DESTRUCTOR: unmap-resource

: free-resource ( resource -- )
    cuGraphicsUnregisterResource cuda-error ; inline

DESTRUCTOR: free-resource

: with-mapped-resource ( ..a resource quot: ( ..a device-ptr size -- ..b ) -- ..b )
    over [ map-resource ] 2dip '[ _ unmap-resource ] [ ] cleanup ; inline
