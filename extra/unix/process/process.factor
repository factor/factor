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
    fork-process dup zero? -roll swap curry if ; inline

: wait-for-pid ( pid -- status )
    0 <int> [ 0 waitpid drop ] keep *int WEXITSTATUS ;

: set-priority ( n -- )
    0 0 rot setpriority io-error ;