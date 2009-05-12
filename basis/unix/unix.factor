! Copyright (C) 2005, 2008 Slava Pestov.
! Copyright (C) 2008 Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax kernel libc
sequences continuations byte-arrays strings math namespaces
system combinators vocabs.loader accessors
stack-checker macros locals generalizations unix.types
io vocabs vocabs.loader ;
IN: unix

CONSTANT: PROT_NONE   0
CONSTANT: PROT_READ   1
CONSTANT: PROT_WRITE  2
CONSTANT: PROT_EXEC   4
                       
CONSTANT: MAP_FILE    0
CONSTANT: MAP_SHARED  1
CONSTANT: MAP_PRIVATE 2

CONSTANT: SEEK_SET 0
CONSTANT: SEEK_CUR 1
CONSTANT: SEEK_END 2

: MAP_FAILED ( -- alien ) -1 <alien> ; inline

CONSTANT: NGROUPS_MAX 16

CONSTANT: DT_UNKNOWN   0
CONSTANT: DT_FIFO      1
CONSTANT: DT_CHR       2
CONSTANT: DT_DIR       4
CONSTANT: DT_BLK       6
CONSTANT: DT_REG       8
CONSTANT: DT_LNK      10
CONSTANT: DT_SOCK     12
CONSTANT: DT_WHT      14

C-STRUCT: group
    { "char*" "gr_name" }
    { "char*" "gr_passwd" }
    { "int" "gr_gid" }
    { "char**" "gr_mem" } ;

LIBRARY: libc

FUNCTION: char* strerror ( int errno ) ;

ERROR: unix-error errno message ;

: (io-error) ( -- * ) errno dup strerror unix-error ;

: io-error ( n -- ) 0 < [ (io-error) ] when ;

ERROR: unix-system-call-error args errno message word ;

MACRO:: unix-system-call ( quot -- )
    [let | n [ quot infer in>> ]
           word [ quot first ] |
        [
            n ndup quot call dup 0 < [
                drop
                n narray
                errno dup strerror
                word unix-system-call-error
            ] [
                n nnip
            ] if
        ]
    ] ;

FUNCTION: int accept ( int s, void* sockaddr, socklen_t* socklen ) ;
FUNCTION: int bind ( int s, void* name, socklen_t namelen ) ;
FUNCTION: int chdir ( char* path ) ;
FUNCTION: int chmod ( char* path, mode_t mode ) ;
FUNCTION: int fchmod ( int fd, mode_t mode ) ;
FUNCTION: int chown ( char* path, uid_t owner, gid_t group ) ;
FUNCTION: int chroot ( char* path ) ;

FUNCTION: int close ( int fd ) ;
FUNCTION: int closedir ( DIR* dirp ) ;

: close-file ( fd -- ) [ close ] unix-system-call drop ;

FUNCTION: int connect ( int s, void* name, socklen_t namelen ) ;
FUNCTION: int dup2 ( int oldd, int newd ) ;
! FUNCTION: int dup ( int oldd ) ;
: _exit ( status -- * )
    #! We throw to give this a terminating stack effect.
    "int" f "_exit" { "int" } alien-invoke "Exit failed" throw ;
FUNCTION: void endpwent ( ) ;
FUNCTION: int fchdir ( int fd ) ;
FUNCTION: int fchown ( int fd, uid_t owner, gid_t group ) ;
FUNCTION: int fcntl ( int fd, int cmd, int arg ) ;
FUNCTION: int flock ( int fd, int operation ) ;
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
FUNCTION: char* getenv ( char* name ) ;

FUNCTION: int getgrgid_r ( gid_t gid, group* grp, char* buffer, size_t bufsize, group** result ) ;
FUNCTION: int getgrnam_r ( char* name, group* grp, char* buffer, size_t bufsize, group** result ) ;
FUNCTION: passwd* getpwent ( ) ;
FUNCTION: passwd* getpwuid ( uid_t uid ) ;
FUNCTION: passwd* getpwnam ( char* login ) ;
FUNCTION: int getpwnam_r ( char* login, passwd* pwd, char* buffer, size_t bufsize, passwd** result ) ;
FUNCTION: int getgroups ( int gidsetlen, gid_t* gidset ) ;
FUNCTION: int getgrouplist ( char* name, int basegid, int* groups, int* ngroups ) ;
FUNCTION: int getrlimit ( int resource, rlimit* rlp ) ;
FUNCTION: int setrlimit ( int resource, rlimit* rlp ) ;

FUNCTION: int getpriority ( int which, id_t who ) ;
FUNCTION: int setpriority ( int which, id_t who, int prio ) ;

FUNCTION: int getrusage ( int who, rusage* r_usage ) ;

FUNCTION: group* getgrent ;
FUNCTION: int gethostname ( char* name, int len ) ;
FUNCTION: int getsockname ( int socket, sockaddr* address, socklen_t* address_len ) ;
FUNCTION: int getpeername ( int socket, sockaddr* address, socklen_t* address_len ) ;
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
FUNCTION: int shutdown ( int fd, int how ) ;

FUNCTION: int open ( char* path, int flags, int prot ) ;

HOOK: open-file os ( path flags mode -- fd )

M: unix open-file [ open ] unix-system-call ;

FUNCTION: DIR* opendir ( char* path ) ;

C-STRUCT: utimbuf
    { "time_t" "actime"  }
    { "time_t" "modtime" } ;

FUNCTION: int utime ( char* path, utimebuf* buf ) ;

: touch ( filename -- ) f [ utime ] unix-system-call drop ;

: change-file-times ( filename access modification -- )
    "utimebuf" <c-object>
    [ set-utimbuf-modtime ] keep
    [ set-utimbuf-actime ] keep
    [ utime ] unix-system-call drop ;

FUNCTION: int pclose ( void* file ) ;
FUNCTION: int pipe ( int* filedes ) ;
FUNCTION: void* popen ( char* command, char* type ) ;
FUNCTION: ssize_t read ( int fd, void* buf, size_t nbytes ) ;

FUNCTION: dirent* readdir ( DIR* dirp ) ;
FUNCTION: int readdir_r ( void* dirp, dirent* entry, dirent** result ) ;
FUNCTION: ssize_t readlink ( char* path, char* buf, size_t bufsize ) ;

CONSTANT: PATH_MAX 1024

: read-symbolic-link ( path -- path )
    PATH_MAX <byte-array> dup [
        PATH_MAX
        [ readlink ] unix-system-call
    ] dip swap head-slice >string ;

FUNCTION: ssize_t recv ( int s, void* buf, size_t nbytes, int flags ) ;
FUNCTION: ssize_t recvfrom ( int s, void* buf, size_t nbytes, int flags, sockaddr-in* from, socklen_t* fromlen ) ;
FUNCTION: int rename ( char* from, char* to ) ;
FUNCTION: int rmdir ( char* path ) ;
FUNCTION: int select ( int nfds, void* readfds, void* writefds, void* exceptfds, timeval* timeout ) ;
FUNCTION: ssize_t sendto ( int s, void* buf, size_t len, int flags, sockaddr-in* to, socklen_t tolen ) ;
FUNCTION: int setenv ( char* name, char* value, int overwrite ) ;
FUNCTION: int unsetenv ( char* name ) ;
FUNCTION: int setegid ( gid_t egid ) ;
FUNCTION: int seteuid ( uid_t euid ) ;
FUNCTION: int setgid ( gid_t gid ) ;
FUNCTION: int setgroups ( int ngroups, gid_t* gidset ) ;
FUNCTION: int setregid ( gid_t rgid, gid_t egid ) ;
FUNCTION: int setreuid ( uid_t ruid, uid_t euid ) ;
FUNCTION: int setsockopt ( int s, int level, int optname, void* optval, socklen_t optlen ) ;
FUNCTION: int setuid ( uid_t uid ) ;
FUNCTION: int socket ( int domain, int type, int protocol ) ;
FUNCTION: int symlink ( char* path1, char* path2 ) ;
FUNCTION: int link ( char* path1, char* path2 ) ;
FUNCTION: int system ( char* command ) ;

FUNCTION: int unlink ( char* path ) ;

: unlink-file ( path -- ) [ unlink ] unix-system-call drop ;

FUNCTION: int utimes ( char* path, timeval[2] times ) ;

FUNCTION: ssize_t write ( int fd, void* buf, size_t nbytes ) ;

{
    { [ os linux? ] [ "unix.linux" require ] }
    { [ os bsd? ] [ "unix.bsd" require ] }
    { [ os solaris? ] [ "unix.solaris" require ] }
} cond

"debugger" vocab [
    "unix.debugger" require
] when
