! Copyright (C) 2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien byte-arrays checksums checksums.common
destructors kernel math sequences sodium sodium.ffi ;
IN: checksums.sodium

TUPLE: sodium-checksum
    { output-size fixnum }
    { key maybe{ byte-array } } ;

INSTANCE: sodium-checksum block-checksum
C: <sodium-checksum> sodium-checksum

<PRIVATE

TUPLE: sodium-state < disposable
    { state alien }
    { output-size fixnum }
    { output maybe{ byte-array } } ;

PRIVATE>

M: sodium-checksum initialize-checksum-state
    [ key>> ] [ output-size>> ] bi
    sodium-state new-disposable swap >>output-size
    crypto_generichash_statebytes sodium_malloc >>state
    [
        [ state>> ] [ drop swap dup length ] [ output-size>> ] tri
        crypto_generichash_init check0
    ] keep ;

M: sodium-state dispose*
    state>> [ sodium_free ] when* ;

M: sodium-state add-checksum-bytes
    [ dup state>> ] dip dup length crypto_generichash_update check0 ;

M: sodium-state get-checksum
    dup output>> [
        dup state>> [
            over output-size>> [ <byte-array> ] keep
            [ crypto_generichash_final check0 ] keepd
        ] [ B{ } clone ] if*
        [ >>output ] keep
    ] unless* nip ;
