! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

USING: alien alien.c-types alien.syntax kernel libc structs
math namespaces system combinators vocabs.loader unix.types ;

IN: unix

TYPEDEF: uint in_addr_t
TYPEDEF: uint socklen_t
TYPEDEF: ulong size_t

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

! ! ! Unix functions
LIBRARY: factor
FUNCTION: int err_no ( ) ;
FUNCTION: void clear_err_no ( ) ;

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
FUNCTION: int getgroups ( int gidsetlen, gid_t* gidset ) ;
FUNCTION: int gethostname ( char* name, int len ) ;
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
FUNCTION: int pclose ( void* file ) ;
FUNCTION: int pipe ( int* filedes ) ;
FUNCTION: void* popen ( char* command, char* type ) ;
FUNCTION: ssize_t read ( int fd, void* buf, size_t nbytes ) ;
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
FUNCTION: int system ( char* command ) ;
FUNCTION: int unlink ( char* path ) ;
FUNCTION: int utimes ( char* path, timeval[2] times ) ;

: SIGKILL 9 ; inline
: SIGTERM 15 ; inline

FUNCTION: int kill ( pid_t pid, int sig ) ;

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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

FUNCTION: ssize_t write ( int fd, void* buf, size_t nbytes ) ;

{
    { [ linux? ] [ "unix.linux" require ] }
    { [ bsd? ] [ "unix.bsd" require ] }
    { [ solaris? ] [ "unix.solaris" require ] }
} cond

