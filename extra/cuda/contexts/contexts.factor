! (c)2010 Joe Groff bsd license
USING: alien.c-types alien.data continuations cuda cuda.ffi
cuda.libraries alien.destructors fry kernel namespaces ;
IN: cuda.contexts

: set-up-cuda-context ( -- )
    H{ } clone cuda-modules set-global
    H{ } clone cuda-functions set-global ; inline

: create-context ( device flags -- context )
    swap
    [ CUcontext <c-object> ] 2dip
    [ cuCtxCreate cuda-error ] 3keep 2drop void* deref ; inline

: sync-context ( -- )
    cuCtxSynchronize cuda-error ; inline

: context-device ( -- n )
    CUdevice <c-object> [ cuCtxGetDevice cuda-error ] keep int deref ; inline

: destroy-context ( context -- ) cuCtxDestroy cuda-error ; inline

: clean-up-context ( context -- )
    [ sync-context ] ignore-errors destroy-context ; inline

DESTRUCTOR: destroy-context
DESTRUCTOR: clean-up-context

: (with-cuda-context) ( context quot -- )
    swap '[ _ clean-up-context ] [ ] cleanup ; inline

: with-cuda-context ( device flags quot -- )
    [ set-up-cuda-context create-context ] dip (with-cuda-context) ; inline

