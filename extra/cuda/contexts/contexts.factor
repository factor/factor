! (c)2010 Joe Groff bsd license
USING: alien.c-types alien.data continuations cuda cuda.ffi
cuda.libraries fry kernel namespaces ;
IN: cuda.contexts

: create-context ( device flags -- context )
    swap
    [ CUcontext <c-object> ] 2dip
    [ cuCtxCreate cuda-error ] 3keep 2drop *void* ; inline

: sync-context ( -- )
    cuCtxSynchronize cuda-error ; inline

: context-device ( -- n )
    CUdevice <c-object> [ cuCtxGetDevice cuda-error ] keep *int ; inline

: destroy-context ( context -- ) cuCtxDestroy cuda-error ; inline

: (set-up-cuda-context) ( device flags create-quot -- )
    H{ } clone cuda-modules set-global
    H{ } clone cuda-functions set
    call ; inline

: (with-cuda-context) ( context quot -- )
    swap '[ [ sync-context ] ignore-errors _ destroy-context ] [ ] cleanup ; inline

: with-cuda-context ( device flags quot -- )
    [ [ create-context ] (set-up-cuda-context) ] dip (with-cuda-context) ; inline

