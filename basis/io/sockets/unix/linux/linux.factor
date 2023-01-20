! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.sockets kernel system ;
IN: io.sockets.unix.linux

! Linux seems to use the same port-space for ipv4 and ipv6.

M: linux resolve-localhost { T{ ipv4 f "0.0.0.0" } } ;
