! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.backend io.launcher io.unix.backend io.nonblocking
sequences kernel namespaces math system alien.c-types debugger
continuations arrays assocs combinators unix.process
parser-combinators memoize promises strings threads ;
IN: io.unix.launcher

! Search unix first
USE: unix

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

: spawn-process ( -- )
    [
        get-arguments
        pass-environment?
        [ get-environment assoc>env exec-args-with-env ]
        [ exec-args-with-path ] if
        io-error
    ] [ error. :c flush ] recover 1 exit ;

M: unix-io run-process* ( desc -- pid )
    [
        [ spawn-process ] [ ] with-fork <process>
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
        spawn-process
    ] [
        -rot 2dup second close first close
    ] with-fork first swap second rot <process> ;

M: unix-io process-stream*
    [
        spawn-process-stream >r handle>duplex-stream r>
    ] with-descriptor ;

: find-process ( handle -- process )
    processes get swap [ nip swap process-handle = ] curry
    assoc-find 2drop ;

! Inefficient process wait polling, used on Linux and Solaris.
! On BSD and Mac OS X, we use kqueue() which scales better.
: wait-for-processes ( -- ? )
    -1 0 <int> tuck WNOHANG waitpid
    dup 0 <= [
        2drop t
    ] [
        find-process dup [
            >r *uint r> notify-exit f
        ] [
            2drop f
        ] if
    ] if ;

: wait-loop ( -- )
    wait-for-processes [ 250 sleep ] when wait-loop ;

: start-wait-thread ( -- )
    [ wait-loop ] in-thread ;
