! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

USING: alien alien.c-types alien.syntax kernel libc structs sequences
       continuations byte-arrays strings
       math namespaces system combinators vocabs.loader qualified
       accessors inference macros fry arrays.lib 
       unix.types ;

IN: unix

TYPEDEF: uint in_addr_t
TYPEDEF: uint socklen_t

: PROT_NONE   0 ; inline
: PROT_READ   1 ; inline
: PROT_WRITE  2 ; inline
: PROT_EXEC   4 ; inline

: MAP_FILE    0 ; inline
: MAP_SHARED  1 ; inline
: MAP_PRIVATE 2 ; inline

: MAP_FAILED -1 <alien> ; inline

: ESRCH 3 ; inline
: EEXIST 17 ; inline

C-STRUCT: group
    { "char*" "gr_name" }
    { "char*" "gr_passwd" }
    { "int" "gr_gid" }
    { "char**" "gr_mem" } ;

C-STRUCT: passwd
    { "char*"  "pw_name" }
    { "char*"  "pw_passwd" }
    { "uid_t"  "pw_uid" }
    { "gid_t"  "pw_gid" }
    { "time_t" "pw_change" }
    { "char*"  "pw_class" }
    { "char*"  "pw_gecos" }
    { "char*"  "pw_dir" }
    { "char*"  "pw_shell" }
    { "time_t" "pw_expire" }
    { "int"    "pw_fields" } ;

LIBRARY: factor

FUNCTION: void clear_err_no ( ) ;
FUNCTION: int err_no ( ) ;

ERROR: unix-system-call-error word args message ;

DEFER: strerror

MACRO: unix-system-call ( quot -- )
    [ ] [ infer in>> ] [ first ] tri
   '[
        [ @ dup 0 < [ dup throw ] [ ] if ]
        [ drop , narray , swap err_no strerror unix-system-call-error ]
        recover
    ] ;

LIBRARY: libc

FUNCTION: int accept ( int s, void* sockaddr, socklen_t* socklen ) ;
FUNCTION: int bind ( int s, void* name, socklen_t namelen ) ;
FUNCTION: int chdir ( char* path ) ;
FUNCTION: int chown ( char* path, uid_t owner, gid_t group ) ;
FUNCTION: int chroot ( char* path ) ;
FUNCTION: void close ( int fd ) ;
FUNCTION: int connect ( int s, void* name, socklen_t namelen ) ;
FUNCTION: int dup2 ( int oldd, int newd ) ;
! FUNCTION: int dup ( int oldd ) ;
FUNCTION: int execv ( char* path, char** argv ) ;
FUNCTION: int execvp ( char* path, char** argv ) ;
FUNCTION: int execve ( char* path, char** argv, char** envp ) ;
: _exit ( status -- * )
    #! We throw to give this a terminating stack effect.
    "int" f "_exit" { "int" } alien-invoke "Exit failed" throw ;
FUNCTION: int fchdir ( int fd ) ;
FUNCTION: int fchown ( int fd, uid_t owner, gid_t group ) ;
FUNCTION: int fcntl ( int fd, int cmd, int arg ) ;
FUNCTION: int flock ( int fd, int operation ) ;
FUNCTION: pid_t fork ( ) ;
FUNCTION: void freeaddrinfo ( addrinfo* ai ) ;
FUNCTION: int futimes ( int id, timeval[2] times ) ;
FUNCTION: char* gai_strerror ( int ecode ) ;
FUNCTION: int getaddrinfo ( char* hostname, char* servname, addrinfo* hints, addrinfo** res ) ;
FUNCTION: char* getcwd ( char* buf, size_t size ) ;
FUNCTION: pid_t getpid ;
FUNCTION: int getdtablesize ;
FUNCTION: gid_t getegid ;
FUNCTION: uid_t geteuid ;
FUNCTION: gid_t getgid ;
FUNCTION: int getgrgid_r ( gid_t gid, group* grp, char* buffer, size_t bufsize, group** result ) ;
FUNCTION: int getgrnam_r ( char* name, group* grp, char* buffer, size_t bufsize, group** result ) ;
FUNCTION: int getpwnam_r ( char* login, passwd* pwd, char* buffer, size_t bufsize, passwd** result ) ;
FUNCTION: int getgroups ( int gidsetlen, gid_t* gidset ) ;
FUNCTION: int gethostname ( char* name, int len ) ;
FUNCTION: int getsockname ( int socket, sockaddr* address, socklen_t* address_len ) ;
FUNCTION: uid_t getuid ;
FUNCTION: uint htonl ( uint n ) ;
FUNCTION: ushort htons ( ushort n ) ;
! FUNCTION: int issetugid ;
FUNCTION: int ioctl ( int fd, ulong request, char* argp ) ;
FUNCTION: int lchown ( char* path, uid_t owner, gid_t group ) ;
FUNCTION: int listen ( int s, int backlog ) ;
FUNCTION: off_t lseek ( int fildes, off_t offset, int whence ) ;
FUNCTION: void* mmap ( void* addr, size_t len, int prot, int flags, int fd, off_t offset ) ;
FUNCTION: int munmap ( void* addr, size_t len ) ;
FUNCTION: uint ntohl ( uint n ) ;
FUNCTION: ushort ntohs ( ushort n ) ;

FUNCTION: int open ( char* path, int flags, int prot ) ;

: open-file ( path flags mode -- fd ) [ open ] unix-system-call ;

C-STRUCT: utimbuf
    { "time_t" "actime"  }
    { "time_t" "modtime" } ;

FUNCTION: int utime ( char* path, utimebuf* buf ) ;

: touch ( filename -- ) f [ utime ] unix-system-call drop ;

: change-file-times ( filename access modification -- )
    "utimebuf" <c-object>
    tuck set-utimbuf-modtime
    tuck set-utimbuf-actime
    [ utime ] unix-system-call drop ;

FUNCTION: int pclose ( void* file ) ;
FUNCTION: int pipe ( int* filedes ) ;
FUNCTION: void* popen ( char* command, char* type ) ;
FUNCTION: ssize_t read ( int fd, void* buf, size_t nbytes ) ;

FUNCTION: ssize_t readlink ( char* path, char* buf, size_t bufsize ) ;

: PATH_MAX 1024 ; inline

: read-symbolic-link ( path -- path )
    PATH_MAX <byte-array> dup >r
    PATH_MAX
    [ readlink ] unix-system-call
    r> swap head-slice >string ;

FUNCTION: ssize_t recv ( int s, void* buf, size_t nbytes, int flags ) ;
FUNCTION: ssize_t recvfrom ( int s, void* buf, size_t nbytes, int flags, sockaddr-in* from, socklen_t* fromlen ) ;
FUNCTION: int rename ( char* from, char* to ) ;
FUNCTION: int rmdir ( char* path ) ;
FUNCTION: int select ( int nfds, void* readfds, void* writefds, void* exceptfds, timeval* timeout ) ;
FUNCTION: ssize_t sendto ( int s, void* buf, size_t len, int flags, sockaddr-in* to, socklen_t tolen ) ;
FUNCTION: int setegid ( gid_t egid ) ;
FUNCTION: int seteuid ( uid_t euid ) ;
FUNCTION: int setgid ( gid_t gid ) ;
FUNCTION: int setgroups ( int ngroups, gid_t* gidset ) ;
FUNCTION: int setregid ( gid_t rgid, gid_t egid ) ;
FUNCTION: int setreuid ( uid_t ruid, uid_t euid ) ;
FUNCTION: int setsockopt ( int s, int level, int optname, void* optval, socklen_t optlen ) ;
FUNCTION: int setuid ( uid_t uid ) ;
FUNCTION: int socket ( int domain, int type, int protocol ) ;
FUNCTION: char* strerror ( int errno ) ;
FUNCTION: int symlink ( char* path1, char* path2 ) ;
FUNCTION: int system ( char* command ) ;

FUNCTION: int unlink ( char* path ) ;

: unlink-file ( path -- ) [ unlink ] unix-system-call drop ;

FUNCTION: int utimes ( char* path, timeval[2] times ) ;

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

FUNCTION: ssize_t write ( int fd, void* buf, size_t nbytes ) ;

{
    { [ os linux? ] [ "unix.linux" require ] }
    { [ os bsd? ] [ "unix.bsd" require ] }
    { [ os solaris? ] [ "unix.solaris" require ] }
} cond

