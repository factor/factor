! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors namespaces assocs kernel io.servers ;
IN: http.server.remapping

SYMBOL: port-remapping

: remap-port ( n -- n' )
    [ port-remapping get at ] keep or ;

: secure-http-port ( -- n )
    secure-addr port>> remap-port ;
