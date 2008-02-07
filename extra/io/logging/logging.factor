! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel io calendar sequences io.files
io.sockets continuations prettyprint ;
IN: io.logging

SYMBOL: log-stream

: to-log-stream ( quot -- )
    log-stream get swap with-stream* ; inline

: log-message ( str -- )
    [
        "[" write now timestamp>string write "] " write
        print flush
    ] to-log-stream ;

: log-error ( str -- ) "Error: " swap append log-message ;

: log-client ( client -- )
    "Accepted connection from "
    swap client-stream-addr unparse append log-message ;

: log-file ( service -- path )
    ".log" append resource-path ;

: with-log-stream ( stream quot -- )
    log-stream get [ nip call ] [
        log-stream swap with-variable
    ] if ; inline

: with-log-file ( file quot -- )
    >r <file-appender> r>
    [ with-log-stream ] curry
    with-disposal ; inline

: with-log-stdio ( quot -- )
    stdio get swap with-log-stream ; inline

: with-logging ( service quot -- )
    over [
        >r log-file
        "Writing log messages to " write dup print flush r>
        with-log-file
    ] [
        nip with-log-stdio
    ] if ; inline
