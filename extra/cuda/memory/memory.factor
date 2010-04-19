! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.data assocs byte-arrays cuda.ffi
cuda.utils destructors io.encodings.string io.encodings.utf8
kernel locals namespaces sequences ;
QUALIFIED-WITH: alien.c-types a
IN: cuda.memory

SYMBOL: cuda-memory-hashtable

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
    [ a:*int ] dip <cuda-memory> add-cuda-memory ;

: cuda-free* ( ptr -- )
    cuMemFree cuda-error ;

M: cuda-memory dispose ( ptr -- )
    ptr>> cuda-free* ;

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

: host>device ( dest-ptr src-ptr -- )
    [ ptr>> ] dip dup length cuMemcpyHtoD cuda-error ;

:: device>host ( ptr -- seq )
    ptr byte-length <byte-array>
    [ ptr [ ptr>> ] [ byte-length ] bi cuMemcpyDtoH cuda-error ] keep ;

: malloc-device-string ( string -- n )
    utf8 encode
    [ length cuda-malloc ] keep
    [ host>device ] [ drop ] 2bi ;
