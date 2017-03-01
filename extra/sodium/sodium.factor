! Copyright (C) 2017 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays init io.encodings.string io.encodings.utf8
kernel math sequences sodium.ffi ;
IN: sodium

ERROR: sodium-init-fail ;
ERROR: call-fail ;

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

[ sodium-init ] "sodium" add-startup-hook
