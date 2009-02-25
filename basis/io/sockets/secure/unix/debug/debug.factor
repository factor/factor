! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io.sockets.secure kernel ;
IN: io.sockets.secure.unix.debug

: with-test-context ( quot -- )
    <secure-config>
        "vocab:openssl/test/server.pem" >>key-file
        "vocab:openssl/test/dh1024.pem" >>dh-file
        "password" >>password
    swap with-secure-context ; inline
