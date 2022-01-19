USING: alien.c-types alien.data alien.syntax alien.utilities
classes.struct environment.unix generalizations
io.encodings.utf8 kernel libc math sequences simple-tokenizer
strings unix unix.types ;
QUALIFIED-WITH: alien.c-types ac
IN: unix.process

! Low-level Unix process launching utilities. These are used
! to implement io.launcher on Unix. User code should use
! io.launcher instead.

FUNCTION: pid_t fork ( )

: call-fork ( -- pid ) [ fork ] unix-system-call ;

FUNCTION: int execv ( c-string path, c-string* argv )
FUNCTION: int execvp ( c-string path, c-string* argv )
FUNCTION: int execve ( c-string path, c-string* argv, c-string* envp )

FUNCTION: int posix_spawn_file_actions_init ( posix_spawn_file_actions_t* file_actions )
FUNCTION: int posix_spawn_file_actions_destroy ( posix_spawn_file_actions_t* file_actions )

FUNCTION: int posix_spawnattr_init ( posix_spawnattr_t* attr )
FUNCTION: int posix_spawnattr_destroy ( posix_spawnattr_t* attr )

FUNCTION: int posix_spawn_file_actions_addclose (
    posix_spawn_file_actions_t *file_actions, int filedes )
FUNCTION: int posix_spawn_file_actions_addopen (
    posix_spawn_file_actions_t* file_actions, int intfiledes, char* path, int oflag, mode_t mode )
FUNCTION: int posix_spawn_file_actions_adddup2 (
    posix_spawn_file_actions_t *file_actions, int filedes, int intnewfiledes )
FUNCTION: int posix_spawn_file_actions_addinherit_np (
    posix_spawn_file_actions_t *file_actions, int filedes )
FUNCTION: int posix_spawn_file_actions_addchdir_np (
    posix_spawn_file_actions_t *file_actions char* path )
FUNCTION: int posix_spawn_file_actions_addfchdir_np (
    posix_spawn_file_actions_t *file_actions, int filedes )

FUNCTION: int posix_spawnattr_getsigdefault ( posix_spawnattr_t* attr, sigset_t* sigdefault )
FUNCTION: int posix_spawnattr_setsigdefault ( posix_spawnattr_t* attr, sigset_t* sigdefault )

FUNCTION: int posix_spawnattr_getflags ( posix_spawnattr_t* attr, ac:short* flags )
FUNCTION: int posix_spawnattr_setflags ( posix_spawnattr_t* attr, ac:short flags )

FUNCTION: int posix_spawnattr_getpgroup ( posix_spawnattr_t* attr, pid_t* pgroup )
FUNCTION: int posix_spawnattr_setpgroup ( posix_spawnattr_t* attr, pid_t pgroup )

FUNCTION: int posix_spawnattr_getsigmask ( posix_spawnattr_t* attr, sigset_t* sigmask )
FUNCTION: int posix_spawnattr_setsigmask ( posix_spawnattr_t* attr, sigset_t* sigmask )

FUNCTION: int sigaddset ( sigset_t* set, int signo )
FUNCTION: int sigdelset ( sigset_t* set, int signo )
FUNCTION: int sigemptyset ( sigset_t* set )
FUNCTION: int sigfillset ( sigset_t* set )
FUNCTION: int sigismember ( sigset_t* set, int signo )

! Not on macOS
FUNCTION: int posix_spawnattr_getschedparam ( posix_spawnattr_t* attr )
FUNCTION: int posix_spawnattr_setschedparam ( posix_spawnattr_t* attr )
FUNCTION: int posix_spawnattr_getschedpolicy ( posix_spawnattr_t* attr )
FUNCTION: int posix_spawnattr_setschedpolicy ( posix_spawnattr_t* attr )

CONSTANT: POSIX_SPAWN_RESETIDS            0x0001
CONSTANT: POSIX_SPAWN_SETPGROUP           0x0002
CONSTANT: POSIX_SPAWN_SETSIGDEF           0x0004
CONSTANT: POSIX_SPAWN_SETSIGMASK          0x0008

CONSTANT: POSIX_SPAWN_SETSCHEDPARAM       0x0010
CONSTANT: POSIX_SPAWN_SETSCHEDULER        0x0020

! Darwin-specific flags
CONSTANT: POSIX_SPAWN_SETEXEC             0x0040
CONSTANT: POSIX_SPAWN_START_SUSPENDED     0x0080
CONSTANT: POSIX_SPAWN_SETSID              0x0400
CONSTANT: POSIX_SPAWN_CLOEXEC_DEFAULT     0x4000

CONSTANT: POSIX_SPAWN_PCONTROL_NONE       0x0000
CONSTANT: POSIX_SPAWN_PCONTROL_THROTTLE   0x0001
CONSTANT: POSIX_SPAWN_PCONTROL_SUSPEND    0x0002
CONSTANT: POSIX_SPAWN_PCONTROL_KILL       0x0003

: check-posix ( n -- )
    dup 0 = [ drop ] [ (throw-errno) ] if ;

: posix-spawn-file-actions-init ( -- posix_spawn_file_actions_t )
    posix_spawn_file_actions_t new
    [ posix_spawn_file_actions_init check-posix ] keep ;

: posix-spawn-file-actions-destroy ( posix_spawn_file_actions_t -- )
    posix_spawn_file_actions_destroy check-posix ;

: posix-spawnattr-init ( -- posix_spawnattr_t )
    f posix_spawnattr_t <ref>
    [ posix_spawnattr_init check-posix ] keep ;

: posix-spawnattr-destroy ( posix_spawnattr_t -- )
    posix_spawnattr_destroy check-posix ;

FUNCTION: int posix_spawn ( pid_t* pid, c-string path,
                       posix_spawn_file_actions_t* file_actions,
                       posix_spawnattr_t* attrp,
                       c-string* argv, c-string* envp )

FUNCTION: int posix_spawnp ( pid_t* pid, c-string file,
                       posix_spawn_file_actions_t* file_actions,
                       posix_spawnattr_t* attrp,
                       c-string* argv, c-string* envp )

: posix-spawn-call ( path posix_spawn_file_actions_t* posix_spawnattr_t* argv envp -- pid_t )
    [ [ 0 pid_t <ref> ] dip utf8 malloc-string ] 4dip
    [ utf8 strings>alien ]
    [ dup sequence? [ utf8 strings>alien ] when ] bi*
    [ posix_spawnp check-posix ] 6 nkeep 5drop pid_t deref ;

: posix-spawn-custom-env ( cmd env -- int )
    [ dup string? [ tokenize ] when ] dip
    [
        [
            first
            posix-spawn-file-actions-init
            posix-spawnattr-init
        ] keep
    ] dip posix-spawn-call ;

: posix-spawn ( cmd -- int )
    environ posix-spawn-custom-env ;

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
    [ call-fork ] 2dip if-zero ; inline

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
