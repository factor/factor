! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel io calendar sequences io.files
io.sockets continuations prettyprint assocs math.parser
words debugger math combinators concurrency arrays init
math.ranges strings ;
IN: logging.server

: log-root ( -- string )
    \ log-root get "logs" resource-path or ;

: log-path ( service -- path )
    log-root swap path+ ;

: log# ( path n -- path' )
    number>string ".log" append path+ ;

SYMBOL: log-files

: open-log-stream ( service -- stream )
    log-path
    dup make-directories
    1 log# <file-appender> ;

: log-stream ( service -- stream )
    log-files get [ open-log-stream ] cache ;

: (write-message) ( msg word-name level multi? -- )
    [
        "[" write 20 CHAR: - <string> write "] " write
    ] [
        "[" write now (timestamp>rfc3339) "] " write
    ] if
    write bl write ": " write print ;

: write-message ( msg word-name level -- )
    rot [ empty? not ] subset {
        { [ dup empty? ] [ 3drop ] }
        { [ dup length 1 = ] [ first -rot f (write-message) ] }
        { [ t ] [
            [ first -rot f (write-message) ] 3keep
            1 tail -rot [ t (write-message) ] 2curry each
        ] }
    } cond ;

: (log-message) ( msg -- )
    #! msg: { msg word-name level service }
    first4 log-stream [ write-message flush ] with-stream* ;

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

: delete-oldest keep-logs log# ?delete-file ;

: ?rename-file ( old new -- )
    over exists? [ rename-file ] [ 2drop ] if ;

: advance-log ( path n -- )
    [ 1- log# ] 2keep log# ?rename-file ;

: rotate-log ( service -- )
    dup close-log
    log-path
    dup delete-oldest
    keep-logs 1 [a,b] [ advance-log ] with each ;

: (rotate-logs) ( -- )
    (close-logs)
    log-root directory [ drop rotate-log ] assoc-each ;

: log-server-loop
    [
        receive unclip {
            { "log-message" [ (log-message) ] }
            { "rotate-logs" [ drop (rotate-logs) ] }
            { "close-logs" [ drop (close-logs) ] }
        } case
    ] [ error. (close-logs) ] recover
    log-server-loop ;

: log-server ( -- )
    [ log-server-loop ] spawn "log-server" set-global ;

[
    H{ } clone log-files set-global
    log-server
] "logging" add-init-hook
