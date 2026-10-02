! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors io.sockets.secure kernel vocabs.loader ;
IN: io.sockets.secure.debug

GENERIC: <test-secure-config>* ( obj -- config )

M: TLSv1 <test-secure-config>*
    drop <secure-config>
        "vocab:openssl/test-1.0/server.pem" >>key-file
        "vocab:openssl/test-1.0/dh2048.pem" >>dh-file
        "password" >>password ;

M: object <test-secure-config>*
    drop <secure-config>
        "vocab:openssl/test-1.2/server.pem" >>key-file
        "vocab:openssl/test-1.2/dh2048.pem" >>dh-file
        "password" >>password ;

HOOK: <test-secure-config> secure-socket-backend ( -- config )

M: object <test-secure-config>
    default-tls-method <test-secure-config>* ;

: with-test-context ( quot -- )
    <test-secure-config>
    swap with-secure-context ; inline

{ "io.sockets.secure.debug" "io.sockets.secure.schannel" }
"io.sockets.secure.debug.schannel" require-when
