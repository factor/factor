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

! crypto_pwhash_H
FUNCTION: int crypto_pwhash_alg_argon2i13 ( )
FUNCTION: int crypto_pwhash_alg_default ( )
FUNCTION: size_t crypto_pwhash_saltbytes ( )
FUNCTION: size_t crypto_pwhash_strbytes ( )
FUNCTION: char* crypto_pwhash_strprefix ( )
FUNCTION: size_t crypto_pwhash_opslimit_interactive ( )
FUNCTION: size_t crypto_pwhash_memlimit_interactive ( )
FUNCTION: size_t crypto_pwhash_opslimit_moderate ( )
FUNCTION: size_t crypto_pwhash_memlimit_moderate ( )
FUNCTION: size_t crypto_pwhash_opslimit_sensitive ( )
FUNCTION: size_t crypto_pwhash_memlimit_sensitive ( )
FUNCTION: int crypto_pwhash (
    uchar* out, ulonglong outlen,
    char* passwd, ulonglong passwdlen,
    uchar* salt,
    ulonglong opslimit, size_t memlimit, int alg )
FUNCTION: int crypto_pwhash_str (
    char* out[crypto_pwhash_STRBYTES],
    char* passwd, ulonglong passwdlen,
    ulonglong opslimit, size_t memlimit )
FUNCTION: int crypto_pwhash_str_verify (
    char* str[crypto_pwhash_STRBYTES],
    char* passwd, ulonglong passwdlen )
FUNCTION: char* crypto_pwhash_primitive ( )
