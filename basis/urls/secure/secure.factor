! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: urls urls.private io.sockets io.sockets.secure ;
IN: urls.secure

UNION: abstract-inet inet inet4 inet6 ;

M: abstract-inet >secure-addr <secure> ;
