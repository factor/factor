! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays assocs
cuda.ffi cuda.utils io.backend kernel namespaces sequences ;
IN: cuda.libraries

SYMBOL: cuda-libraries
cuda-libraries [ H{ } clone ] initialize

SYMBOL: current-cuda-library

TUPLE: cuda-library name path handle ;

: <cuda-library> ( name path -- obj )
    \ cuda-library new
        swap >>path
        swap >>name ;

: add-cuda-library ( name path -- )
    normalize-path <cuda-library>
    dup name>> cuda-libraries get-global set-at ;

: ?delete-at ( key assoc -- old/key ? )
    2dup delete-at* [ 2nip t ] [ 2drop f ] if ; inline

ERROR: no-cuda-library name ;

: load-module ( path -- module )
    [ CUmodule <c-object> ] dip
    [ cuModuleLoad cuda-error ] 2keep drop *void* ;

: unload-module ( module -- )
    cuModuleUnload cuda-error ;

: load-cuda-library ( library -- handle )
    path>> load-module ;

: lookup-cuda-library ( name -- cuda-library )
    cuda-libraries get ?at [ no-cuda-library ] unless ;

: remove-cuda-library ( name -- library )
    cuda-libraries get ?delete-at [ no-cuda-library ] unless ;

: unload-cuda-library ( name -- )
    remove-cuda-library handle>> unload-module ;

: cached-module ( module-name -- alien )
    lookup-cuda-library
    cuda-modules get-global [ load-cuda-library ] cache ;

: cached-function ( module-name function-name -- alien )
    [ cached-module ] dip
    2array cuda-functions get [ first2 get-function-ptr* ] cache ;
