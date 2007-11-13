! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.launcher io.unix.backend io.nonblocking
sequences kernel namespaces math system alien.c-types
debugger continuations arrays assocs combinators ;
IN: io.unix.launcher

! Search unix first
USE: unix

: with-fork ( child parent -- pid )
    fork [ zero? -rot if ] keep ; inline

: get-arguments ( -- seq )
    +command+ get
    [ "/bin/sh" "-c" rot 3array ] [ +arguments+ get ] if* ;

: >null-term-array f add >c-void*-array ;

: prepare-execvp ( -- cmd args )
    #! Doesn't free any memory, so we only call this word
    #! after forking.
    get-arguments
    [ malloc-char-string ] map
    dup first swap >null-term-array ;

: prepare-execve ( -- cmd args env )
    #! Doesn't free any memory, so we only call this word
    #! after forking.
    prepare-execvp
    get-environment
    [ "=" swap 3append malloc-char-string ] { } assoc>map
    >null-term-array ;

: (spawn-process) ( -- )
    [
        pass-environment? [
            prepare-execve execve
        ] [
            prepare-execvp execvp
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
        2dup second close first close
    ] with-fork >r first swap second r> ;

TUPLE: pipe-stream pid ;

: <pipe-stream> ( in out pid -- stream )
    pipe-stream construct-boa
    -rot handle>duplex-stream over set-delegate ;

M: pipe-stream stream-close
    dup delegate stream-close
    pipe-stream-pid wait-for-process ;

M: unix-io process-stream*
    [ spawn-process-stream <pipe-stream> ] with-descriptor ;
