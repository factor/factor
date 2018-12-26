! Copyright (C) 2017, 2018 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
classes.struct combinators system ;
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
FUNCTION: void sodium_memzero ( void* pnt, size_t len )
FUNCTION: void sodium_stackzero ( size_t len )
FUNCTION: int sodium_memcmp (
    void* b1_, void* b2_, size_t len )
FUNCTION: int sodium_compare (
    uchar* b1_, uchar* b2_, size_t len )
FUNCTION: int sodium_is_zero ( uchar* n, size_t nlen )
FUNCTION: void sodium_increment ( uchar* n, size_t nlen )
FUNCTION: void sodium_add ( uchar* a, uchar* b, size_t len )
FUNCTION: char* sodium_bin2hex (
    char* hex, size_t hex_maxlen,
    uchar* bin, size_t bin_len )
FUNCTION: int sodium_hex2bin (
    uchar* bin, size_t bin_maxlen,
    char* hex, size_t hex_len,
    char* ignore, size_t* bin_len,
    char** hex_end )
CONSTANT: sodium_base64_VARIANT_ORIGINAL            1
CONSTANT: sodium_base64_VARIANT_ORIGINAL_NO_PADDING 3
CONSTANT: sodium_base64_VARIANT_URLSAFE             5
CONSTANT: sodium_base64_VARIANT_URLSAFE_NO_PADDING  7
FUNCTION: size_t sodium_base64_encoded_len ( size_t bin_len, int variant )
FUNCTION: char* sodium_bin2base64 (
    char* b64, size_t b64_maxlen,
    uchar* bin, size_t bin_len,
    int variant )
FUNCTION: int sodium_base642bin (
    uchar* bin, size_t bin_maxlen,
    char* b64, size_t b64_len,
    char* ignore, size_t* bin_len,
    char** b64_end, int variant )
FUNCTION: int sodium_mlock ( void* addr, size_t len )
FUNCTION: int sodium_munlock ( void* addr, size_t len )
FUNCTION: void* sodium_malloc ( size_t size )
FUNCTION: void* sodium_allocarray ( size_t count, size_t size )
FUNCTION: void sodium_free ( void* ptr )
FUNCTION: int sodium_mprotect_noaccess ( void* ptr )
FUNCTION: int sodium_mprotect_readonly ( void* ptr )
FUNCTION: int sodium_mprotect_readwrite ( void* ptr )
FUNCTION: int sodium_pad (
    size_t* padded_buflen_p, uchar* buf,
    size_t unpadded_buflen, size_t blocksize, size_t max_buflen )
FUNCTION: int sodium_unpad (
    size_t* unpadded_buflen_p, uchar* buf,
    size_t padded_buflen, size_t blocksize )

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
FUNCTION: char* crypto_secretbox_primitive ( )
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
    uchar* m, uchar* c, uchar* mac, ulonglong clen,
    uchar* n, uchar* k )
FUNCTION: void crypto_secretbox_keygen (
    uchar k[crypto_secretbox_keybytes] )

! crypto_box_H
FUNCTION: size_t crypto_box_seedbytes ( )
FUNCTION: size_t crypto_box_publickeybytes ( )
FUNCTION: size_t crypto_box_secretkeybytes ( )
FUNCTION: size_t crypto_box_noncebytes ( )
FUNCTION: size_t crypto_box_macbytes ( )
FUNCTION: size_t crypto_box_messagebytes_max ( )
FUNCTION: char* crypto_box_primitive ( )
FUNCTION: int crypto_box_seed_keypair (
    uchar* pk, uchar* sk, uchar* seed )
FUNCTION: int crypto_box_keypair ( uchar* pk, uchar* sk )
FUNCTION: int crypto_box_easy (
    uchar* c, uchar* m, ulonglong mlen, uchar* n,
    uchar* pk, uchar* sk )
FUNCTION: int crypto_box_open_easy (
    uchar* m, uchar* c, ulonglong clen, uchar* n,
    uchar* pk, uchar* sk )
FUNCTION: int crypto_box_detached (
    uchar* c, uchar* mac, uchar* m, ulonglong mlen, uchar* n,
    uchar* pk, uchar* sk )
FUNCTION: int crypto_box_open_detached (
    uchar* m, uchar* c, uchar* mac, ulonglong clen, uchar* n,
    uchar* pk, uchar* sk )
FUNCTION: size_t crypto_box_beforenmbytes ( )
FUNCTION: int crypto_box_beforenm (
    uchar* k, uchar* pk, uchar* sk )
FUNCTION: int crypto_box_easy_afternm (
    uchar* c, uchar* m, ulonglong mlen, uchar* n, uchar* k )
FUNCTION: int crypto_box_open_easy_afternm (
    uchar* m, uchar* c, ulonglong clen, uchar* n, uchar* k )
FUNCTION: int crypto_box_detached_afternm (
    uchar* c, uchar* mac, uchar* m, ulonglong mlen, uchar* n, uchar* k )
FUNCTION: int crypto_box_open_detached_afternm (
    uchar* m, uchar* c, uchar* mac, ulonglong clen, uchar* n, uchar* k )
FUNCTION: size_t crypto_box_sealbytes ( )
FUNCTION: int crypto_box_seal (
    uchar* c, uchar* m, ulonglong mlen, uchar* pk )
FUNCTION: int crypto_box_seal_open (
    uchar* m, uchar* c, ulonglong clen, uchar* pk, uchar* sk )

! crypto_auth_H
FUNCTION: size_t crypto_auth_bytes ( )
FUNCTION: size_t crypto_auth_keybytes ( )
FUNCTION: char* crypto_auth_primitive ( )
FUNCTION: int crypto_auth (
    uchar* out, uchar* in, ulonglong inlen, uchar* k )
FUNCTION: int crypto_auth_verify (
    uchar* h, uchar* in, ulonglong inlen, uchar* k )
FUNCTION: void crypto_auth_keygen ( uchar k[crypto_auth_keybytes] )

! crypto_kdf_H
FUNCTION: size_t crypto_kdf_bytes_min ( )
FUNCTION: size_t crypto_kdf_bytes_max ( )
FUNCTION: size_t crypto_kdf_contextbytes ( )
FUNCTION: size_t crypto_kdf_keybytes ( )
FUNCTION: char* crypto_kdf_primitive ( )
FUNCTION: int crypto_kdf_derive_from_key (
    uchar* subkey, size_t subkey_len,
    uint64_t subkey_id,
    char ctx[crypto_kdf_contextbytes],
    uchar key[crypto_kdf_keybytes] )
FUNCTION: void crypto_kdf_keygen ( uchar k[crypto_kdf_keybytes] )

! crypto_kx_H
FUNCTION: size_t crypto_kx_publickeybytes ( )
FUNCTION: size_t crypto_kx_secretkeybytes ( )
FUNCTION: size_t crypto_kx_seedbytes ( )
FUNCTION: size_t crypto_kx_sessionkeybytes ( )
FUNCTION: char* crypto_kx_primitive ( )
FUNCTION: int crypto_kx_seed_keypair (
    uchar pk[crypto_kx_publickeybytes],
    uchar sk[crypto_kx_secretkeybytes],
    uchar seed[crypto_kx_seedbytes] )
FUNCTION: int crypto_kx_keypair (
    uchar pk[crypto_kx_publickeybytes],
    uchar sk[crypto_kx_secretkeybytes] )
FUNCTION: int crypto_kx_client_session_keys (
    uchar rx[crypto_kx_sessionkeybytes],
    uchar tx[crypto_kx_sessionkeybytes],
    uchar client_pk[crypto_kx_publickeybytes],
    uchar client_sk[crypto_kx_secretkeybytes],
    uchar server_pk[crypto_kx_publickeybytes] )
FUNCTION: int crypto_kx_server_session_keys (
    uchar rx[crypto_kx_sessionkeybytes],
    uchar tx[crypto_kx_sessionkeybytes],
    uchar server_pk[crypto_kx_publickeybytes],
    uchar server_sk[crypto_kx_secretkeybytes],
    uchar client_pk[crypto_kx_publickeybytes] )

! crypto_onetimeauth_H
STRUCT: crypto_onetimeauth_state
    { opaque uchar[256] }
;
FUNCTION: size_t crypto_onetimeauth_statebytes ( )
FUNCTION: size_t crypto_onetimeauth_bytes ( )
FUNCTION: size_t crypto_onetimeauth_keybytes ( )
FUNCTION: char* crypto_onetimeauth_primitive ( )
FUNCTION: int crypto_onetimeauth (
    uchar* out, uchar* in, ulonglong inlen, uchar* k )
FUNCTION: int crypto_onetimeauth_verify (
    uchar* h, uchar* in, ulonglong inlen, uchar* k )
FUNCTION: int crypto_onetimeauth_init (
    crypto_onetimeauth_state *state, uchar* key )
FUNCTION: int crypto_onetimeauth_update (
    crypto_onetimeauth_state *state, uchar* in, ulonglong inlen )
FUNCTION: int crypto_onetimeauth_final (
    crypto_onetimeauth_state *state, uchar* out )
FUNCTION: void crypto_onetimeauth_keygen (
    uchar k[crypto_onetimeauth_keybytes] )

! crypto_sign_H
STRUCT: crypto_hash_sha512_state
    { state uint64_t[8] }
    { count uint64_t[2] }
    { buf uint8_t[128] }
;
STRUCT: crypto_sign_state
    { hs crypto_hash_sha512_state }
;
FUNCTION: size_t crypto_sign_statebytes ( )
FUNCTION: size_t crypto_sign_bytes ( )
FUNCTION: size_t crypto_sign_seedbytes ( )
FUNCTION: size_t crypto_sign_publickeybytes ( )
FUNCTION: size_t crypto_sign_secretkeybytes ( )
FUNCTION: size_t crypto_sign_messagebytes_max ( )
FUNCTION: char* crypto_sign_primitive ( )
FUNCTION: int crypto_sign_seed_keypair (
    uchar* pk, uchar* sk, uchar* seed )
FUNCTION: int crypto_sign_keypair ( uchar* pk, uchar* sk )
FUNCTION: int crypto_sign (
    uchar* sm, ulonglong *smlen_p,
    uchar* m, ulonglong mlen,
    uchar* sk )
FUNCTION: int crypto_sign_open (
    uchar* m, ulonglong *mlen_p,
    uchar* sm, ulonglong smlen,
    uchar* pk )
FUNCTION: int crypto_sign_detached (
    uchar* sig, ulonglong *siglen_p,
    uchar* m, ulonglong mlen,
    uchar* sk )
FUNCTION: int crypto_sign_verify_detached (
    uchar* sig, uchar* m, ulonglong mlen, uchar* pk )
FUNCTION: int crypto_sign_init ( crypto_sign_state *state )
FUNCTION: int crypto_sign_update (
    crypto_sign_state *state, uchar* m, ulonglong mlen )
FUNCTION: int crypto_sign_final_create (
    crypto_sign_state *state, uchar* sig, ulonglong *siglen_p, uchar* sk )
FUNCTION: int crypto_sign_final_verify (
    crypto_sign_state *state, uchar* sig, uchar* pk )

! crypto_aead_xchacha20poly1305_H
FUNCTION: size_t crypto_aead_xchacha20poly1305_ietf_keybytes ( )
FUNCTION: size_t crypto_aead_xchacha20poly1305_ietf_nsecbytes ( )
FUNCTION: size_t crypto_aead_xchacha20poly1305_ietf_npubbytes ( )
FUNCTION: size_t crypto_aead_xchacha20poly1305_ietf_abytes ( )
FUNCTION: size_t crypto_aead_xchacha20poly1305_ietf_messagebytes_max ( )
FUNCTION: int crypto_aead_xchacha20poly1305_ietf_encrypt (
    uchar* c, ulonglong* clen_p,
    uchar* m, ulonglong mlen,
    uchar* ad, ulonglong adlen,
    uchar* nsec, uchar* npub, uchar* k )
FUNCTION: int crypto_aead_xchacha20poly1305_ietf_decrypt (
    uchar* m, ulonglong* mlen_p, uchar* nsec,
    uchar* c, ulonglong clen,
    uchar* ad, ulonglong adlen,
    uchar* npub, uchar* k )
FUNCTION: int crypto_aead_xchacha20poly1305_ietf_encrypt_detached (
    uchar* c, uchar* mac, ulonglong* maclen_p,
    uchar* m, ulonglong mlen,
    uchar* ad, ulonglong adlen,
    uchar* nsec, uchar* npub, uchar* k )
FUNCTION: int crypto_aead_xchacha20poly1305_ietf_decrypt_detached (
    uchar* m, uchar* nsec,
    uchar* c, ulonglong clen,
    uchar* mac,
    uchar* ad, ulonglong adlen,
    uchar* npub, uchar* k )
FUNCTION: void crypto_aead_xchacha20poly1305_ietf_keygen (
    uchar k[crypto_aead_xchacha20poly1305_ietf_keybytes] )

! crypto_secretstream_xchacha20poly1305_H
FUNCTION: size_t crypto_secretstream_xchacha20poly1305_abytes ( )
FUNCTION: size_t crypto_secretstream_xchacha20poly1305_headerbytes ( )
FUNCTION: size_t crypto_secretstream_xchacha20poly1305_keybytes ( )
FUNCTION: size_t crypto_secretstream_xchacha20poly1305_messagebytes_max ( )
FUNCTION: uchar crypto_secretstream_xchacha20poly1305_tag_message ( )
FUNCTION: uchar crypto_secretstream_xchacha20poly1305_tag_push ( )
FUNCTION: uchar crypto_secretstream_xchacha20poly1305_tag_rekey ( )
FUNCTION: uchar crypto_secretstream_xchacha20poly1305_tag_final ( )
CONSTANT: crypto_stream_chacha20_ietf_KEYBYTES 32
CONSTANT: crypto_stream_chacha20_ietf_NONCEBYTES 12
STRUCT: crypto_secretstream_xchacha20poly1305_state
    { k uchar[crypto_stream_chacha20_ietf_KEYBYTES] }
    { nonce uchar[crypto_stream_chacha20_ietf_NONCEBYTES] }
    { _pad uchar[8] }
;
FUNCTION: size_t crypto_secretstream_xchacha20poly1305_statebytes ( )
FUNCTION: void crypto_secretstream_xchacha20poly1305_keygen (
    uchar k[crypto_secretstream_xchacha20poly1305_keybytes] )
FUNCTION: int crypto_secretstream_xchacha20poly1305_init_push (
    crypto_secretstream_xchacha20poly1305_state* state,
    uchar header[crypto_secretstream_xchacha20poly1305_headerbytes],
    uchar k[crypto_secretstream_xchacha20poly1305_keybytes] )
FUNCTION: int crypto_secretstream_xchacha20poly1305_push (
    crypto_secretstream_xchacha20poly1305_state* state,
    uchar* c, ulonglong* clen_p,
    uchar* m, ulonglong mlen,
    uchar* ad, ulonglong adlen, uchar tag )
FUNCTION: int crypto_secretstream_xchacha20poly1305_init_pull (
    crypto_secretstream_xchacha20poly1305_state* state,
    uchar header[crypto_secretstream_xchacha20poly1305_headerbytes],
    uchar k[crypto_secretstream_xchacha20poly1305_keybytes] )
FUNCTION: int crypto_secretstream_xchacha20poly1305_pull (
    crypto_secretstream_xchacha20poly1305_state* state,
    uchar* m, ulonglong* mlen_p, uchar* tag_p,
    uchar* c, ulonglong clen,
    uchar* ad, ulonglong adlen )
FUNCTION: void crypto_secretstream_xchacha20poly1305_rekey (
     crypto_secretstream_xchacha20poly1305_state* state )

! sodium_runtime_H
FUNCTION: int sodium_runtime_has_neon ( )
FUNCTION: int sodium_runtime_has_sse2 ( )
FUNCTION: int sodium_runtime_has_sse3 ( )
FUNCTION: int sodium_runtime_has_ssse3 ( )
FUNCTION: int sodium_runtime_has_sse41 ( )
FUNCTION: int sodium_runtime_has_avx ( )
FUNCTION: int sodium_runtime_has_avx2 ( )
FUNCTION: int sodium_runtime_has_avx512f ( )
FUNCTION: int sodium_runtime_has_pclmul ( )
FUNCTION: int sodium_runtime_has_aesni ( )
FUNCTION: int sodium_runtime_has_rdrand ( )
