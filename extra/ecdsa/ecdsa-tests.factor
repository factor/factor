! Copyright (C) 2009 Maxim Savchenko
! See http://factorcode.org/license.txt for BSD license.

USING: namespaces ecdsa tools.test checksums checksums.sha2 ;
IN: ecdsa.tests

SYMBOLS: priv-key pub-key signature ;

: message ( -- msg ) "Hello world!" ;

[ ] ! Generating keys
[
    "prime256v1" [ generate-key get-private-key get-public-key ] with-ec
    pub-key set priv-key set
] unit-test

[ ] ! Signing message
[
    message sha-256 checksum-bytes
    priv-key get
    "prime256v1" [ set-private-key ecdsa-sign ] with-ec
    signature set
] unit-test

[ t ] ! Verifying signature
[
    message sha-256 checksum-bytes
    signature get pub-key get
    "prime256v1" [ set-public-key ecdsa-verify ] with-ec
] unit-test