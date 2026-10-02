! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors io.sockets.secure io.sockets.secure.debug
io.sockets.secure.schannel kernel ;
IN: io.sockets.secure.debug.schannel

M: schannel <test-secure-config>
    <secure-config> f >>verify
        "vocab:io/sockets/secure/schannel/server.pfx" >>key-file
        "password" >>password ;
