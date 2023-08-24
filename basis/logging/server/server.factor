! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs calendar calendar.format combinators
concurrency.messaging continuations debugger destructors init io
io.directories io.encodings.utf8 io.files io.pathnames kernel
math math.parser ranges namespaces sequences strings threads ;
IN: logging.server

: log-root ( -- string )
    \ log-root get-global [ "logs" resource-path ] unless* ;

: log-path ( service -- path )
    log-root prepend-path ;

: log# ( path n -- path' )
    number>string ".log" append append-path ;

SYMBOL: log-files

: open-log-stream ( service -- stream )
    log-path
    [ make-directories ]
    [ 1 log# utf8 <file-appender> ] bi ;

: log-stream ( service -- stream )
    log-files get [ open-log-stream ] cache ;

: close-log-streams ( -- )
    log-files get [ values dispose-each ] [ clear-assoc ] bi ;

:: with-log-root ( path quot -- )
    [ close-log-streams path \ log-root set-global quot call ]
    \ log-root get-global
    [ \ log-root set-global close-log-streams ] curry
    finally ; inline

: timestamp-header. ( -- )
    "[" write now write-rfc3339 "] " write ;

: multiline-header ( -- str ) 20 CHAR: - <string> ; foldable

: multiline-header. ( -- )
    "[" write multiline-header write "] " write ;

:: write-message ( msg word-name level -- )
    msg harvest [
        timestamp-header.
        [ multiline-header. ]
        [ level write bl word-name write ": " write print ]
        interleave
    ] unless-empty ;

: (log-message) ( msg -- )
    ! msg: { msg word-name level service }
    first4 log-stream [ write-message flush ] with-output-stream* ;

: try-dispose ( obj -- )
    [ dispose ] curry [ error. ] recover ;

: close-log ( service -- )
    log-files get delete-at*
    [ try-dispose ] [ drop ] if ;

: (close-logs) ( -- )
    log-files get
    [ values [ try-dispose ] each ] [ clear-assoc ] bi ;

CONSTANT: keep-logs 10

: delete-oldest ( service -- )
    keep-logs log# ?delete-file ;

: advance-log ( path n -- )
    [ 1 - log# ] 2keep log# ?move-file ;

: rotate-log ( service -- )
    [ close-log ]
    [
        log-path
        [ delete-oldest ]
        [ keep-logs 1 [a..b] [ advance-log ] with each ] bi
    ] bi ;

: (rotate-logs) ( -- )
    (close-logs)
    log-root directory-files [ rotate-log ] each ;

: log-server-loop ( -- )
    receive unclip {
        { "log-message" [ (log-message) ] }
        { "rotate-logs" [ drop (rotate-logs) ] }
        { "close-logs" [ drop (close-logs) ] }
    } case log-server-loop ;

: log-server ( -- )
    [
        init-namestack
        [ log-server-loop ]
        [ error. (close-logs) ]
        recover t
    ]
    "Log server" spawn-server
    "log-server" set-global ;

STARTUP-HOOK: [
    H{ } clone log-files set-global
    log-server
]
