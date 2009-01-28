! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel io calendar sequences io.files
io.sockets continuations destructors prettyprint assocs
math.parser words debugger math combinators
concurrency.messaging threads arrays init math.ranges strings
calendar.format io.encodings.utf8 ;
IN: logging.server

: log-root ( -- string )
    \ log-root get "logs" resource-path or ;

: log-path ( service -- path )
    log-root prepend-path ;

: log# ( path n -- path' )
    number>string ".log" append append-path ;

SYMBOL: log-files

: open-log-stream ( service -- stream )
    log-path
    dup make-directories
    1 log# utf8 <file-appender> ;

: log-stream ( service -- stream )
    log-files get [ open-log-stream ] cache ;

: multiline-header ( -- string ) 20 CHAR: - <string> ; foldable

: (write-message) ( msg name>> level multi? -- )
    [
        "[" write multiline-header write "] " write
    ] [
        "[" write now (timestamp>rfc3339) "] " write
    ] if
    write bl write ": " write print ;

: write-message ( msg name>> level -- )
    rot harvest {
        { [ dup empty? ] [ 3drop ] }
        { [ dup length 1 = ] [ first -rot f (write-message) ] }
        [
            [ first -rot f (write-message) ] 3keep
            rest -rot [ t (write-message) ] 2curry each
        ]
    } cond ;

: (log-message) ( msg -- )
    #! msg: { msg name>> level service }
    first4 log-stream [ write-message flush ] with-output-stream* ;

: try-dispose ( stream -- )
    [ dispose ] curry [ error. ] recover ;

: close-log ( service -- )
    log-files get delete-at*
    [ try-dispose ] [ drop ] if ;

: (close-logs) ( -- )
    log-files get
    dup values [ try-dispose ] each
    clear-assoc ;

: keep-logs 10 ;

: ?delete-file ( path -- )
    dup exists? [ delete-file ] [ drop ] if ;

: delete-oldest ( service -- ) keep-logs log# ?delete-file ;

: ?move-file ( old new -- )
    over exists? [ move-file ] [ 2drop ] if ;

: advance-log ( path n -- )
    [ 1- log# ] 2keep log# ?move-file ;

: rotate-log ( service -- )
    dup close-log
    log-path
    dup delete-oldest
    keep-logs 1 [a,b] [ advance-log ] with each ;

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
        init-namespaces
        [ log-server-loop ]
        [ error. (close-logs) ]
        recover t
    ]
    "Log server" spawn-server
    "log-server" set-global ;

[
    H{ } clone log-files set-global
    log-server
] "logging" add-init-hook
