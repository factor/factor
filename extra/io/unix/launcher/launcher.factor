! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.backend io.launcher io.unix.backend io.nonblocking
sequences kernel namespaces math system alien.c-types debugger
continuations arrays assocs combinators unix.process
parser-combinators memoize promises strings ;
IN: io.unix.launcher

! Search unix first
USE: unix

HOOK: wait-for-process io-backend ( pid -- status )

M: unix-io wait-for-process ( pid -- status ) wait-for-pid ;

! Our command line parser. Supported syntax:
! foo bar baz -- simple tokens
! foo\ bar -- escaping the space
! 'foo bar' -- quotation
! "foo bar" -- quotation
LAZY: 'escaped-char' "\\" token any-char-parser &> ;

LAZY: 'quoted-char' ( delimiter -- parser' )
    'escaped-char'
    swap [ member? not ] curry satisfy
    <|> ; inline

LAZY: 'quoted' ( delimiter -- parser )
    dup 'quoted-char' <!*> swap dup surrounded-by ;

LAZY: 'unquoted' ( -- parser ) " '\"" 'quoted-char' <!+> ;

LAZY: 'argument' ( -- parser )
    "\"" 'quoted' "'" 'quoted' 'unquoted' <|> <|>
    [ >string ] <@ ;

MEMO: 'arguments' ( -- parser )
    'argument' " " token <!+> nonempty-list-of ;

: tokenize-command ( command -- arguments )
    'arguments' just parse-1 ;

: get-arguments ( -- seq )
    +command+ get [ tokenize-command ] [ +arguments+ get ] if* ;

: assoc>env ( assoc -- env )
    [ "=" swap 3append ] { } assoc>map ;

: (spawn-process) ( -- )
    [
        get-arguments
        pass-environment?
        [ get-environment assoc>env exec-args-with-env ]
        [ exec-args-with-path ] if
        io-error
    ] [ error. :c flush ] recover 1 exit ;

: spawn-process ( -- pid )
    [ (spawn-process) ] [ ] with-fork ;

: spawn-detached ( -- )
    [ spawn-process 0 exit ] [ ] with-fork
    wait-for-process drop ;

M: unix-io run-process* ( desc -- )
    [
        +detached+ get [
            spawn-detached
        ] [
            spawn-process wait-for-process drop
        ] if
    ] with-descriptor ;

: open-pipe ( -- pair )
    2 "int" <c-array> dup pipe zero?
    [ 2 c-int-array> ] [ drop f ] if ;

: setup-stdio-pipe ( stdin stdout -- )
    2dup first close second close
    >r first 0 dup2 drop r> second 1 dup2 drop ;

: spawn-process-stream ( -- in out pid )
    open-pipe open-pipe [
        setup-stdio-pipe
        (spawn-process)
    ] [
        -rot 2dup second close first close
    ] with-fork first swap second rot ;

TUPLE: pipe-stream pid status ;

: <pipe-stream> ( in out pid -- stream )
    f pipe-stream construct-boa
    -rot handle>duplex-stream over set-delegate ;

M: pipe-stream stream-close
    dup delegate stream-close
    dup pipe-stream-pid wait-for-process
    swap set-pipe-stream-status ;

M: unix-io process-stream*
    [ spawn-process-stream <pipe-stream> ] with-descriptor ;
