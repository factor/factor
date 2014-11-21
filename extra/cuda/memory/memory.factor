! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.data alien.destructors assocs
byte-arrays cuda cuda.ffi destructors fry io.encodings.string
io.encodings.utf8 kernel locals math namespaces sequences
strings ;
QUALIFIED-WITH: alien.c-types c
IN: cuda.memory

: cuda-malloc ( n -- ptr )
    [ { CUdeviceptr } ] dip
    '[ _ cuMemAlloc cuda-error ] with-out-parameters ; inline

: cuda-malloc-type ( n type -- ptr )
    c:heap-size * cuda-malloc ; inline

: cuda-free ( ptr -- )
    cuMemFree cuda-error ; inline

DESTRUCTOR: cuda-free

: memcpy-device>device ( dest-ptr src-ptr count -- )
    cuMemcpyDtoD cuda-error ; inline

: memcpy-device>array ( dest-array dest-index src-ptr count -- )
    cuMemcpyDtoA cuda-error ; inline

: memcpy-array>device ( dest-ptr src-array src-index count -- )
    cuMemcpyAtoD cuda-error ; inline

: memcpy-array>host ( dest-ptr src-array src-index count -- )
    cuMemcpyAtoH cuda-error ; inline

: memcpy-host>array ( dest-array dest-index src-ptr count -- )
    cuMemcpyHtoA cuda-error ; inline

: memcpy-array>array ( dest-array dest-index src-array src-ptr count -- )
    cuMemcpyAtoA cuda-error ; inline

: memcpy-host>device ( dest-ptr src-ptr count -- )
    cuMemcpyHtoD cuda-error ; inline

: memcpy-device>host ( dest-ptr src-ptr count -- )
    cuMemcpyDtoH cuda-error ; inline

: host>device ( data -- ptr )
    binary-object
    [ nip cuda-malloc dup ] [ memcpy-host>device ] 2bi ; inline

: device>host ( ptr len -- byte-array )
    [ nip <byte-array> dup ] [ memcpy-device>host ] 2bi ; inline
