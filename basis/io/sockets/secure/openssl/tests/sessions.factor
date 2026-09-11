USING: accessors alien.libraries alien.c-types alien.data alien.syntax assocs
continuations destructors io.sockets.secure io.sockets.secure.openssl
kernel libc locals math openssl openssl.libssl sequences tools.test ;
IN: io.sockets.secure.openssl.session-tests

! Observe real OpenSSL reference destruction using its ex_data free callback.
LIBRARY: libcrypto
CALLBACK: void session-free-callback ( void* parent, void* ptr, void* ad,
    int index, long argl, void* argp )
FUNCTION: int CRYPTO_get_ex_new_index ( int class, long argl, void* argp,
    void* new_func, void* dup_func, session-free-callback free_func )
FUNCTION: int CRYPTO_free_ex_index ( int class, int index )
LIBRARY: libssl
FUNCTION: SSL_SESSION* SSL_SESSION_new ( )
FUNCTION: int SSL_SESSION_set_ex_data ( SSL_SESSION* session, int index, void* data )

: count-freed-session ( -- callback )
    [| parent ptr ad index argl argp |
        ptr [ ptr uint deref 1 + ptr 0 uint set-alien-value ] when
    ] session-free-callback ;

:: tracked-session ( index counter -- session )
    SSL_SESSION_new dup ssl-error :> session
    [ session index counter SSL_SESSION_set_ex_data ssl-error session ]
    [ ] [ session SSL_SESSION_free ] cleanup ;

"CRYPTO_free_ex_index" "libcrypto" dlsym? [
{ 1 256 302 } [
    [
      [let
        maybe-init-ssl
        0 uint <ref> malloc-byte-array &free :> counter
        2 0 f f f count-freed-session CRYPTO_get_ex_new_index :> index
        [
        <secure-config> [
            index counter tracked-session "same-host" save-session
            index counter tracked-session "same-host" save-session
            counter uint deref
            300 [ index counter tracked-session swap save-session ] each-integer
            current-secure-context sessions>> assoc-size
        ] with-secure-context
        counter uint deref
        ] [ 2 index CRYPTO_free_ex_index drop ] finally
      ]
    ] with-destructors
] unit-test

] when
