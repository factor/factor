IN: io.unix.launcher
USING: io io.launcher io.unix.backend io.nonblocking
sequences kernel namespaces math system alien.c-types
debugger continuations ;

! Search unix first
USE: unix

: with-fork ( quot -- pid )
    fork [ zero? -rot if ] keep ; inline

: prepare-execvp ( args -- cmd args )
    #! Doesn't free any memory, so we only call this word
    #! after forking.
    [ malloc-char-string ] map
    [ first ] keep
    f add >c-void*-array ;

: (spawn-process) ( args -- )
    [ prepare-execvp execvp ] catch 1 exit ;

: spawn-process ( args -- pid )
    [ (spawn-process) ] [ drop ] with-fork ;

: wait-for-process ( pid -- )
    0 <int> 0 waitpid drop ;

: shell-command ( string -- args )
    { "/bin/sh" "-c" } swap add ;

M: unix-io run-process ( string -- )
    shell-command spawn-process wait-for-process ;

: detached-shell-command ( string -- args )
    shell-command "&" add ;

M: unix-io run-detached ( string -- )
    detached-shell-command spawn-process wait-for-process ;

: open-pipe ( -- pair )
    2 "int" <c-array> dup pipe zero?
    [ 2 c-int-array> ] [ drop f ] if ;

: setup-stdio-pipe ( stdin stdout -- )
    2dup first close second close
    >r first 0 dup2 drop r> second 1 dup2 drop ;

: spawn-process-stream ( args -- in out pid )
    open-pipe open-pipe [
        setup-stdio-pipe
        (spawn-process)
    ] [
        2dup second close first close
        rot drop
    ] with-fork >r first swap second r> ;

TUPLE: pipe-stream pid ;

: <pipe-stream> ( in out pid -- stream )
    pipe-stream construct-boa
    -rot handle>duplex-stream over set-delegate ;

M: pipe-stream stream-close
    dup delegate stream-close
    pipe-stream-pid wait-for-process ;

M: unix-io <process-stream>
    shell-command spawn-process-stream <pipe-stream> ;
