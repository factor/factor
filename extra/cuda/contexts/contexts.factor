! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data continuations cuda cuda.ffi
cuda.libraries alien.destructors fry kernel namespaces ;
IN: cuda.contexts

: set-up-cuda-context ( -- )
    H{ } clone cuda-modules set-global
    H{ } clone cuda-functions set-global ; inline

: create-context ( device flags -- context )
    swap
    [ { CUcontext } ] 2dip
    '[ _ _ cuCtxCreate cuda-error ] with-out-parameters ; inline

: sync-context ( -- )
    cuCtxSynchronize cuda-error ; inline

: context-device ( -- n )
    { CUdevice } [ cuCtxGetDevice cuda-error ] with-out-parameters ; inline

: destroy-context ( context -- ) cuCtxDestroy cuda-error ; inline

: clean-up-context ( context -- )
    [ sync-context ] ignore-errors destroy-context ; inline

DESTRUCTOR: destroy-context
DESTRUCTOR: clean-up-context

: (with-cuda-context) ( context quot -- )
    swap '[ _ clean-up-context ] finally ; inline

: with-cuda-context ( device flags quot -- )
    [ set-up-cuda-context create-context ] dip (with-cuda-context) ; inline
