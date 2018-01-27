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

! sodium_utils_H
FUNCTION: void* sodium_malloc ( size_t size )
FUNCTION: void* sodium_allocarray ( size_t count, size_t size )
FUNCTION: void sodium_free ( void* ptr )
FUNCTION: int sodium_mprotect_noaccess ( void* ptr )
FUNCTION: int sodium_mprotect_readonly ( void* ptr )
FUNCTION: int sodium_mprotect_readwrite ( void* ptr )

! crypto_generichash_H
TYPEDEF: void* crypto_generichash_state
FUNCTION: size_t crypto_generichash_bytes_min ( )
FUNCTION: size_t crypto_generichash_bytes_max ( )
FUNCTION: size_t crypto_generichash_bytes ( )
FUNCTION: size_t crypto_generichash_keybytes_min ( )
FUNCTION: size_t crypto_generichash_keybytes_max ( )
FUNCTION: size_t crypto_generichash_keybytes ( )
FUNCTION: char* crypto_generichash_primitive ( )
FUNCTION: size_t crypto_generichash_statebytes ( )
FUNCTION: int crypto_generichash (
    uchar* out, size_t outlen,
    uchar* in, ulonglong inlen,
    uchar* key, size_t keylen )
FUNCTION: int crypto_generichash_init (
    crypto_generichash_state* state,
    uchar* key, size_t keylen, size_t outlen )
FUNCTION: int crypto_generichash_update (
    crypto_generichash_state* state, uchar* in, ulonglong inlen )
FUNCTION: int crypto_generichash_final (
    crypto_generichash_state* state, uchar* out, size_t outlen )

! crypto_secretbox_H
FUNCTION: size_t crypto_secretbox_keybytes ( )
FUNCTION: size_t crypto_secretbox_noncebytes ( )
FUNCTION: size_t crypto_secretbox_macbytes ( )
FUNCTION: char *crypto_secretbox_primitive ( )
FUNCTION: int crypto_secretbox_easy (
    uchar* c, uchar* m, ulonglong mlen,
    uchar* n, uchar* k )
FUNCTION: int crypto_secretbox_open_easy (
    uchar* m, uchar* c, ulonglong clen,
    uchar* n, uchar* k )
FUNCTION: int crypto_secretbox_detached (
    uchar* c, uchar* mac, uchar* m, ulonglong mlen,
    uchar* n, uchar* k )
FUNCTION: int crypto_secretbox_open_detached (
    uchar *m, uchar* c, uchar* mac, ulonglong clen,
    uchar* n, uchar* k )
FUNCTION: void crypto_secretbox_keygen (
    uchar k[crypto_secretbox_KEYBYTES] )
