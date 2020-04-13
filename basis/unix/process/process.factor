USING: alien.c-types alien.data alien.syntax classes.struct
generalizations io.encodings.utf8 kernel libc math sequences
unix unix.types unix.utilities ;
IN: unix.process

! Low-level Unix process launching utilities. These are used
! to implement io.launcher on Unix. User code should use
! io.launcher instead.

FUNCTION: pid_t fork ( )

: fork-process ( -- pid ) [ fork ] unix-system-call ;

FUNCTION: int execv ( c-string path, c-string* argv )
FUNCTION: int execvp ( c-string path, c-string* argv )
FUNCTION: int execve ( c-string path, c-string* argv, c-string* envp )


TYPEDEF: void posix_spawn_file_actions_t
TYPEDEF: void posix_spawnattr_t

FUNCTION: int posix_spawn ( pid_t *pid, c-string path,
                       posix_spawn_file_actions_t *file_actions,
                       posix_spawnattr_t *attrp,
                       c-string* argv, c-string* envp )

FUNCTION: int posix_spawnp ( pid_t *pid, c-string file,
                       posix_spawn_file_actions_t *file_actions,
                       posix_spawnattr_t *attrp,
                       c-string* argv, c-string* envp )

: posix-spawn ( path posix_spawn_file_actions_t* posix_spawnattr_t* argv envp -- pid_t )
    [ [ 0 pid_t <ref> ] dip utf8 malloc-string ] 4dip
    [ utf8 strings>alien ] bi@
    [
        posix_spawnp dup 0 = [ drop ] [ throw-errno ] if
    ] 6 nkeep 5drop pid_t deref ;

: posix-spawn-args-with-path ( seq -- int )
    [ first f f ] keep f posix-spawn ;

: exec ( pathname argv -- int )
    [ utf8 malloc-string ] [ utf8 strings>alien ] bi* execv ;

: exec-with-path ( filename argv -- int )
    [ utf8 malloc-string ] [ utf8 strings>alien ] bi* execvp ;

: exec-with-env ( filename argv envp -- int )
    [ utf8 malloc-string ]
    [ utf8 strings>alien ]
    [ utf8 strings>alien ] tri* execve ;

: exec-args ( seq -- int )
    [ first ] keep exec ;

: exec-args-with-path ( seq -- int )
    [ first ] keep exec-with-path ;

: exec-args-with-env  ( seq seq -- int )
    [ [ first ] keep ] dip exec-with-env ;

: with-fork ( child parent -- )
    [ fork-process ] 2dip if-zero ; inline

FUNCTION: int kill ( pid_t pid, int sig )
FUNCTION: int raise ( int sig )


CONSTANT: PRIO_PROCESS 0
CONSTANT: PRIO_PGRP 1
CONSTANT: PRIO_USER 2

CONSTANT: PRIO_MIN -20
CONSTANT: PRIO_MAX 20

! which/who = 0 for current process
FUNCTION: int getpriority ( int which, int who )
FUNCTION: int setpriority ( int which, int who, int prio )

: set-priority ( n -- )
    [ 0 0 ] dip setpriority io-error ;

! Flags for waitpid

CONSTANT: WNOHANG   1
CONSTANT: WUNTRACED 2

CONSTANT: WSTOPPED   2
CONSTANT: WEXITED    4
CONSTANT: WCONTINUED 8
CONSTANT: WNOWAIT    0x1000000

! Examining status

: WTERMSIG ( status -- value )
    0x7f bitand ; inline

: WIFEXITED ( status -- ? )
    WTERMSIG 0 = ; inline

: WEXITSTATUS ( status -- value )
    0xff00 bitand -8 shift ; inline

: WIFSIGNALED ( status -- ? )
    0x7f bitand 1 + -1 shift 0 > ; inline

: WCOREFLAG ( -- value )
    0x80 ; inline

: WCOREDUMP ( status -- ? )
    WCOREFLAG bitand 0 = not ; inline

: WIFSTOPPED ( status -- ? )
    0xff bitand 0x7f = ; inline

: WSTOPSIG ( status -- value )
    WEXITSTATUS ; inline

FUNCTION: pid_t wait ( int* status )
FUNCTION: pid_t waitpid ( pid_t wpid, int* status, int options )
