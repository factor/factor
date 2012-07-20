! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io.sockets.secure kernel ;
IN: io.sockets.secure.debug

: <test-secure-config> ( -- config )
    <secure-config>
        "vocab:openssl/test/server.pem" >>key-file
        "vocab:openssl/test/dh1024.pem" >>dh-file
        "password" >>password ;

: with-test-context ( quot -- )
    <test-secure-config>
    swap with-secure-context ; inline
