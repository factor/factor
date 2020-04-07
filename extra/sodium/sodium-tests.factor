! Copyright (C) 2018 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays io.encodings.string io.encodings.utf8 kernel math
sequences sodium tools.test ;
IN: sodium.tests

{ t } [
    "Encrypted message" dup utf8 encode
    crypto-box-nonce 2 [ crypto-box-keypair 2array ] times
    [ [ first ] [ second ] bi* crypto-box-easy ] 3keep swap
    [ first ] [ second ] bi* crypto-box-open-easy utf8 decode =
] unit-test

{ t } [
    "Signature verification test" utf8 encode
    crypto-sign-keypair
    [ nip crypto-sign ]
    [ drop crypto-sign-verify ] 3bi
] unit-test
