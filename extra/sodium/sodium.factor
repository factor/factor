! Copyright (C) 2017-2020 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data byte-arrays init io.encodings.ascii
io.encodings.string io.encodings.utf8 kernel locals math sequences
sodium.ffi ;
IN: sodium

ERROR: sodium-init-fail ;
ERROR: call-fail ;
ERROR: buffer-too-small ;

! Call this before any other function, may be called multiple times.
: sodium-init ( -- ) sodium_init 0 < [ sodium-init-fail ] when ;

<PRIVATE

: cipher-buf ( message-length n -- byte-array )
    + <byte-array> ;

: message-buf ( cipher-length n -- byte-array )
    - <byte-array> ;

: secretbox-cipher-buf ( message-length -- byte-array )
    crypto_secretbox_macbytes cipher-buf ;

: secretbox-message-buf ( cipher-length -- byte-array )
    crypto_secretbox_macbytes message-buf ;

: box-cipher-buf ( message-length -- byte-array )
    crypto_box_macbytes cipher-buf ;

: box-message-buf ( cipher-length -- byte-array )
    crypto_box_macbytes message-buf ;

PRIVATE>

: random-bytes ( byte-array -- byte-array' )
    dup dup length randombytes_buf ;

: n-random-bytes ( n -- byte-array )
    <byte-array> random-bytes ;

: check0 ( n -- ) 0 = [ call-fail ] unless ;

ERROR: sodium-malloc-error ;

: check-malloc ( ptr -- ptr/* )
    dup [ sodium-malloc-error ] unless ;

: sodium-malloc ( size -- ptr )
    sodium_malloc check-malloc ;

: crypto-pwhash-str ( password opslimit memlimit -- str )
    [ crypto_pwhash_strbytes <byte-array> dup ] 3dip
    [ utf8 encode dup length ] 2dip crypto_pwhash_str check0
    utf8 decode ;

: crypto-pwhash-str-verify ( str password -- ? )
    [ utf8 encode ] bi@ dup length crypto_pwhash_str_verify 0 = ;

: crypto-generichash ( out-bytes in-bytes key-bytes/f -- out-bytes' )
    [ dup ] 2dip [ dup length ] tri@ crypto_generichash check0 ;

: check-length ( byte-array min-length -- byte-array )
    [ dup length ] dip < [ buffer-too-small ] when ;

: crypto-secretbox-easy ( msg-bytes nonce-bytes key-bytes -- cipher-bytes )
    [ dup length [ secretbox-cipher-buf swap dupd ] keep ]
    [ crypto_secretbox_noncebytes check-length ]
    [ crypto_secretbox_keybytes check-length ] tri*
    crypto_secretbox_easy check0 ;

: crypto-secretbox-open-easy ( cipher-bytes nonce-bytes key-bytes -- msg-bytes/f )
    [
        crypto_secretbox_macbytes check-length
        dup length [ secretbox-message-buf swap dupd ] keep
    ]
    [ crypto_secretbox_noncebytes check-length ]
    [ crypto_secretbox_keybytes check-length ] tri*
    crypto_secretbox_open_easy 0 = and* ;

: crypto-box-keypair ( -- public-key secret-key )
    crypto_box_publickeybytes <byte-array>
    crypto_box_secretkeybytes <byte-array>
    2dup crypto_box_keypair check0 ;

: crypto-sign-keypair ( -- public-key secret-key )
    crypto_sign_publickeybytes <byte-array>
    crypto_sign_secretkeybytes <byte-array>
    2dup crypto_sign_keypair check0 ;

: crypto-sign ( message secret-key -- signature )
    [ crypto_sign_bytes <byte-array> dup f ] 2dip
    [ dup length ] dip crypto_sign_detached check0 ;

: crypto-sign-verify ( signature message public-key -- ? )
    [ dup length ] dip crypto_sign_verify_detached 0 = ;

: crypto-box-nonce ( -- nonce-bytes )
    crypto_box_noncebytes n-random-bytes ;

: crypto-box-easy ( message nonce public-key private-key -- cipher-bytes )
    [
        dup length [ box-cipher-buf dup rot ] keep
    ] 3dip crypto_box_easy check0 ;

: crypto-box-open-easy ( cipher-bytes nonce public-key private-key -- message )
    [
        dup length [ box-message-buf dup rot ] keep
    ] 3dip crypto_box_open_easy check0 ;

:: sodium-base64>bin ( string -- byte-array )
    string length dup <byte-array> dup :> bin swap
    string ascii encode dup length f 0 size_t <ref> dup :> bin-length f
    sodium_base64_VARIANT_URLSAFE_NO_PADDING sodium_base642bin check0
    bin bin-length size_t deref head ;

: (base64-buffer) ( bin -- len byte-array )
    length sodium_base64_VARIANT_URLSAFE_NO_PADDING sodium_base64_encoded_len
    dup <byte-array> ;

:: sodium-bin>base64 ( byte-array -- string )
    byte-array (base64-buffer) dup :> b64 swap
    byte-array dup length sodium_base64_VARIANT_URLSAFE_NO_PADDING
    sodium_bin2base64 0 = [ call-fail ] when b64 ascii decode unclip-last
    CHAR: \0 = [ call-fail ] unless ;

STARTUP-HOOK: sodium-init
