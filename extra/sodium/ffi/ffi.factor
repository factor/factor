! Copyright (C) 2017 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
combinators system ;
IN: sodium.ffi

<< "sodium" {
    { [ os windows? ] [ "libsodium.dll" ] }
    { [ os macosx? ] [ "libsodium.dylib" ] }
    { [ os unix? ] [ "libsodium.so" ] }
} cond cdecl add-library >>

LIBRARY: sodium

FUNCTION: int sodium_init ( )

! randombytes_H
FUNCTION: void randombytes_buf ( void* buf, size_t size )
FUNCTION: uint32_t randombytes_random ( )
FUNCTION: uint32_t randombytes_uniform ( uint32_t upper_bound )
FUNCTION: void randombytes_stir ( )
