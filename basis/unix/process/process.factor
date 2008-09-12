USING: kernel alien.c-types alien.strings sequences math alien.syntax unix
       vectors kernel namespaces continuations threads assocs vectors
       io.unix.backend io.encodings.utf8 ;
IN: unix.process

! Low-level Unix process launching utilities. These are used
! to implement io.launcher on Unix. User code should use
! io.launcher instead.

FUNCTION: pid_t fork ( ) ;

: fork-process ( -- pid ) [ fork ] unix-system-call ;

FUNCTION: int execv ( char* path, char** argv ) ;
FUNCTION: int execvp ( char* path, char** argv ) ;
FUNCTION: int execve ( char* path, char** argv, char** envp ) ;

: >argv ( seq -- alien )
    [ utf8 malloc-string ] map f suffix >c-void*-array ;

: exec ( pathname argv -- int )
    [ utf8 malloc-string ] [ >argv ] bi* execv ;

: exec-with-path ( filename argv -- int )
    [ utf8 malloc-string ] [ >argv ] bi* execvp ;

: exec-with-env ( filename argv envp -- int )
    [ utf8 malloc-string ] [ >argv ] [ >argv ] tri* execve ;

: exec-args ( seq -- int )
    [ first ] [ ] bi exec ;

: exec-args-with-path ( seq -- int )
    [ first ] [ ] bi exec-with-path ;

: exec-args-with-env  ( seq seq -- int )
    >r [ first ] [ ] bi r> exec-with-env ;

: with-fork ( child parent -- )
    [ [ fork-process dup zero? ] dip [ drop ] prepose ] dip
    if ; inline

: SIGKILL 9 ; inline
: SIGTERM 15 ; inline

FUNCTION: int kill ( pid_t pid, int sig ) ;

: PRIO_PROCESS 0 ; inline
: PRIO_PGRP 1 ; inline
: PRIO_USER 2 ; inline

: PRIO_MIN -20 ; inline
: PRIO_MAX 20 ; inline

! which/who = 0 for current process
FUNCTION: int getpriority ( int which, int who ) ;
FUNCTION: int setpriority ( int which, int who, int prio ) ;

: set-priority ( n -- )
    0 0 rot setpriority io-error ;

! Flags for waitpid

: WNOHANG   1 ; inline
: WUNTRACED 2 ; inline

: WSTOPPED   2 ; inline
: WEXITED    4 ; inline
: WCONTINUED 8 ; inline
: WNOWAIT    HEX: 1000000 ; inline

! Examining status

: WTERMSIG ( status -- value )
    HEX: 7f bitand ; inline

: WIFEXITED ( status -- ? )
    WTERMSIG zero? ; inline

: WEXITSTATUS ( status -- value )
    HEX: ff00 bitand -8 shift ; inline

: WIFSIGNALED ( status -- ? )
    HEX: 7f bitand 1+ -1 shift 0 > ; inline

: WCOREFLAG ( -- value )
    HEX: 80 ; inline

: WCOREDUMP ( status -- ? )
    WCOREFLAG bitand zero? not ; inline

: WIFSTOPPED ( status -- ? )
    HEX: ff bitand HEX: 7f = ; inline

: WSTOPSIG ( status -- value )
    WEXITSTATUS ; inline

FUNCTION: pid_t wait ( int* status ) ;
FUNCTION: pid_t waitpid ( pid_t wpid, int* status, int options ) ;

: wait-for-pid ( pid -- status )
    0 <int> [ 0 waitpid drop ] keep *int WEXITSTATUS ;