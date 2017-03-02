! Copyright (C) 2017 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays init io.encodings.string io.encodings.utf8
kernel math sequences sodium.ffi ;
IN: sodium

ERROR: sodium-init-fail ;
ERROR: call-fail ;
ERROR: buffer-too-small ;

! Call this before any other function, may be called multiple times.
: sodium-init ( -- ) sodium_init 0 < [ sodium-init-fail ] when ;

: random-bytes ( byte-array -- byte-array' )
    dup dup length randombytes_buf ;

: n-random-bytes ( n -- byte-array )
    <byte-array> random-bytes ;

: check0 ( n -- ) 0 = [ call-fail ] unless ;

: crypto-pwhash-str ( password opslimit memlimit -- str )
    [ crypto_pwhash_strbytes <byte-array> dup ] 3dip
    [ utf8 encode dup length ] 2dip crypto_pwhash_str check0
    utf8 decode ;

: crypto-pwhash-str-verify ( str password -- bool )
    [ utf8 encode ] bi@ dup length crypto_pwhash_str_verify 0 = ;

: crypto-generichash ( out-bytes in-bytes key-bytes/f -- out-bytes' )
    [ dup ] 2dip [ dup length ] tri@ crypto_generichash check0 ;

: cipher-buf ( msg-length -- byte-array )
    crypto_secretbox_macbytes + <byte-array> ;

: message-buf ( msg-length -- byte-array )
    crypto_secretbox_macbytes - <byte-array> ;

: check-length ( byte-array min-length -- byte-array )
    [ dup length ] dip < [ buffer-too-small ] when ;

: crypto-secretbox-easy ( msg-bytes nonce-bytes key-bytes -- cipher-bytes )
    [ dup length [ cipher-buf swap dupd ] keep ]
    [ crypto_secretbox_noncebytes check-length ]
    [ crypto_secretbox_keybytes check-length ] tri*
    crypto_secretbox_easy check0 ;

: crypto-secretbox-open-easy ( cipher-bytes nonce-bytes key-bytes -- msg-bytes/f )
    [
        crypto_secretbox_macbytes check-length
        dup length [ message-buf swap dupd ] keep
    ]
    [ crypto_secretbox_noncebytes check-length ]
    [ crypto_secretbox_keybytes check-length ] tri*
    crypto_secretbox_open_easy 0 = [ drop f ] unless ;

[ sodium-init ] "sodium" add-startup-hook
