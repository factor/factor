USING: kernel alien.c-types alien.data alien.strings sequences
math alien.syntax unix namespaces continuations threads assocs
io.backend.unix io.encodings.utf8 unix.utilities fry ;
IN: unix.process

! Low-level Unix process launching utilities. These are used
! to implement io.launcher on Unix. User code should use
! io.launcher instead.

FUNCTION: pid_t fork ( ) ;

: fork-process ( -- pid ) [ fork ] unix-system-call ;

FUNCTION: int execv ( char* path, char** argv ) ;
FUNCTION: int execvp ( char* path, char** argv ) ;
FUNCTION: int execve ( char* path, char** argv, char** envp ) ;

: exec ( pathname argv -- int )
    [ utf8 malloc-string ] [ utf8 strings>alien ] bi* execv ;

: exec-with-path ( filename argv -- int )
    [ utf8 malloc-string ] [ utf8 strings>alien ] bi* execvp ;

: exec-with-env ( filename argv envp -- int )
    [ utf8 malloc-string ]
    [ utf8 strings>alien ]
    [ utf8 strings>alien ] tri* execve ;

: exec-args ( seq -- int )
    [ first ] [ ] bi exec ;

: exec-args-with-path ( seq -- int )
    [ first ] [ ] bi exec-with-path ;

: exec-args-with-env  ( seq seq -- int )
    [ [ first ] [ ] bi ] dip exec-with-env ;

: with-fork ( child parent -- )
    [ [ fork-process dup zero? ] dip '[ drop @ ] ] dip
    if ; inline

CONSTANT: SIGKILL 9
CONSTANT: SIGTERM 15

FUNCTION: int kill ( pid_t pid, int sig ) ;

CONSTANT: PRIO_PROCESS 0
CONSTANT: PRIO_PGRP 1
CONSTANT: PRIO_USER 2

CONSTANT: PRIO_MIN -20
CONSTANT: PRIO_MAX 20

! which/who = 0 for current process
FUNCTION: int getpriority ( int which, int who ) ;
FUNCTION: int setpriority ( int which, int who, int prio ) ;

: set-priority ( n -- )
    [ 0 0 ] dip setpriority io-error ;

! Flags for waitpid

CONSTANT: WNOHANG   1
CONSTANT: WUNTRACED 2

CONSTANT: WSTOPPED   2
CONSTANT: WEXITED    4
CONSTANT: WCONTINUED 8
CONSTANT: WNOWAIT    HEX: 1000000

! Examining status

: WTERMSIG ( status -- value )
    HEX: 7f bitand ; inline

: WIFEXITED ( status -- ? )
    WTERMSIG 0 = ; inline

: WEXITSTATUS ( status -- value )
    HEX: ff00 bitand -8 shift ; inline

: WIFSIGNALED ( status -- ? )
    HEX: 7f bitand 1 + -1 shift 0 > ; inline

: WCOREFLAG ( -- value )
    HEX: 80 ; inline

: WCOREDUMP ( status -- ? )
    WCOREFLAG bitand 0 = not ; inline

: WIFSTOPPED ( status -- ? )
    HEX: ff bitand HEX: 7f = ; inline

: WSTOPSIG ( status -- value )
    WEXITSTATUS ; inline

FUNCTION: pid_t wait ( int* status ) ;
FUNCTION: pid_t waitpid ( pid_t wpid, int* status, int options ) ;

: wait-for-pid ( pid -- status )
    0 <int> [ 0 waitpid drop ] keep *int WEXITSTATUS ;
