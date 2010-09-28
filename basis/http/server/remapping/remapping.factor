! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs kernel io.servers ;
IN: http.server.remapping

SYMBOL: port-remapping

: remap-port ( n -- n' )
    [ port-remapping get at ] keep or ;

: secure-http-port ( -- n )
    secure-port remap-port ;
