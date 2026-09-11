USING: accessors alien alien.c-types arrays alien.data alien.strings
byte-arrays destructors io.encodings.utf8 io.sockets.secure
io.sockets.secure.openssl io.sockets.secure.openssl.private kernel libc
locals math namespaces classes.struct openssl openssl.libcrypto
openssl.libssl sequences strings tools.test ;
IN: io.sockets.secure.openssl.audit-tests

: with-identity-certificate ( quot -- )
    maybe-init-ssl
    [
        "resource:basis/io/sockets/secure/openssl/identity-test.pem" <file-bio> &dispose
        handle>> f f f PEM_read_bio_X509 &X509_free swap call
    ] with-destructors ; inline

{ { t f t f f t f t f } } [
    [
        { "good.example" "cn-only.example" "a.wild.example"
          "wild.example" "a.b.wild.example" "127.0.0.1"
          "127.0.0.2" "::1" "good.example\0.invalid" }
        swap [ certificate-matches? ] curry map
    ] with-identity-certificate
] unit-test

{ { "good.example" "*.wild.example" } } [
    [ alternative-dns-names ] with-identity-certificate
] unit-test

{ f } [ ".example" "*.example" subject-names-match? ] unit-test

{ B{ 2 104 50 8 104 116 116 112 47 49 46 49 } } [
    { "h2" "http/1.1" } alpn-wire-format
] unit-test
[ { "" } alpn-wire-format ] [ invalid-alpn-protocol? ] must-fail-with
[ 256 CHAR: a <string> 1array alpn-wire-format ]
[ invalid-alpn-protocol? ] must-fail-with

: call-alpn-callback ( ssl out outlen in inlen arg callback -- result )
    int { void* void* void* void* uint void* } cdecl alien-indirect ;

! Selected ALPN data must point inside the native peer buffer.
{ t 2 0 } [
  [ [let
    alpn_select_cb_func :> callback
    B{ 2 104 50 } malloc-byte-array &free :> configured
    alpn-protocols malloc-struct &free configured >>data 3 >>length :> protocols
    B{ 2 104 50 } malloc-byte-array &free :> peer
    f void* <ref> :> selected
    0 uchar <ref> :> selected-length
    f selected selected-length peer 3 protocols callback
    call-alpn-callback :> result
    selected void* deref alien-address
    peer alien-address 1 + =
    selected-length uchar deref result
  ] ] with-destructors
] unit-test

: call-password-callback ( buf size rwflag password callback -- length )
    int { void* int bool void* } cdecl alien-indirect ;

{ 3 B{ 97 98 99 77 88 } } [
    [
      [let
        B{ 0 0 0 77 88 } malloc-byte-array &free :> buffer
        "abcdef" utf8 malloc-string &free :> password
        buffer 3 f password password-callback call-password-callback
        buffer 5 memory>byte-array
      ]
    ] with-destructors
] unit-test

: with-test-context-variable ( context quot -- result )
    secure-context swap with-variable ; inline

TUPLE: audit-file < disposable ;
M: audit-file dispose* drop ;

! Disposing a context cannot release callback userdata while an SSL uses it.
{ 1 0 } [
    [
      [let
        <secure-config> { "h2" } >>alpn-supported-protocols
        <secure-context> &dispose :> context
        context [ audit-file new-disposable <ssl-handle> &dispose ]
        with-test-context-variable :> handle
        context dispose context users>>
        handle dispose context users>>
      ]
    ] with-destructors
] unit-test
