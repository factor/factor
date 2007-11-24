! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.launcher io.unix.backend io.nonblocking
sequences kernel namespaces math system alien.c-types
debugger continuations arrays assocs combinators unix.process
parser-combinators memoize promises strings ;
IN: io.unix.launcher

! Search unix first
USE: unix

! Our command line parser. Supported syntax:
! foo bar baz -- simple tokens
! foo\ bar -- escaping the space
! 'foo bar' -- quotation
! "foo bar" -- quotation
LAZY: 'escaped-char' "\\" token any-char-parser &> ;

LAZY: 'chars' 'escaped-char' any-char-parser <|> <*> ;

LAZY: 'non-space-char'
    'escaped-char' [ CHAR: \s = not ] satisfy <|> ;

LAZY: 'quoted-1' 'chars' "\"" "\"" surrounded-by ;

LAZY: 'quoted-2' 'chars' "'" "'" surrounded-by ;

LAZY: 'unquoted' 'non-space-char' <+> ;

LAZY: 'argument'
    'quoted-1' 'quoted-2' 'unquoted' <|> <|>
    [ >string ] <@ ;

MEMO: 'arguments' ( -- parser )
    'argument' " " token <+> list-of ;

: tokenize-command ( command -- arguments )
    'arguments' parse-1 ;

: get-arguments ( -- seq )
    +command+ get [ tokenize-command ] [ +arguments+ get ] if* ;

: assoc>env ( assoc -- env )
    [ "=" swap 3append ] { } assoc>map ;

: (spawn-process) ( -- )
    [
        pass-environment? [
	    get-arguments get-environment assoc>env exec-args-with-env
        ] [
	    get-arguments exec-args-with-path
        ] if io-error
    ] [ error. :c flush ] recover 1 exit ;

: wait-for-process ( pid -- )
    0 <int> 0 waitpid drop ;

: spawn-process ( -- pid )
    [ (spawn-process) ] [ ] with-fork ;

: spawn-detached ( -- )
    [ spawn-process 0 exit ] [ ] with-fork wait-for-process ;

M: unix-io run-process* ( desc -- )
    [
        +detached+ get [
            spawn-detached
        ] [
            spawn-process wait-for-process
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

TUPLE: pipe-stream pid ;

: <pipe-stream> ( in out pid -- stream )
    pipe-stream construct-boa
    -rot handle>duplex-stream over set-delegate ;

M: pipe-stream stream-close
    dup delegate stream-close
    pipe-stream-pid wait-for-process ;

M: unix-io process-stream*
    [ spawn-process-stream <pipe-stream> ] with-descriptor ;
