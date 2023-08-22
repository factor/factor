! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.libraries
alien.syntax classes.struct sequences system unix.time
unix.types vocabs ;
IN: unix.ffi

<< "unix.ffi." os name>> append require >>

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

CONSTANT: DT_UNKNOWN   0
CONSTANT: DT_FIFO      1
CONSTANT: DT_CHR       2
CONSTANT: DT_DIR       4
CONSTANT: DT_BLK       6
CONSTANT: DT_REG       8
CONSTANT: DT_LNK      10
CONSTANT: DT_SOCK     12
CONSTANT: DT_WHT      14

: SIG_EFF ( -- obj ) ALIEN: -1 void* <ref> ; inline
: SIG_DFL ( -- obj ) ALIEN: 0 void* <ref> ; inline
: SIG_IGN ( -- obj ) ALIEN: 1 void* <ref> ; inline

! Possible values for 'ai_flags' in 'addrinfo'.
CONSTANT: AI_PASSIVE        0x0001
CONSTANT: AI_CANONNAME      0x0002
CONSTANT: AI_NUMERICHOST    0x0004
CONSTANT: AI_V4MAPPED       0x0008
CONSTANT: AI_ALL            0x0010
CONSTANT: AI_ADDRCONFIG     0x0020

CONSTANT: SHUT_RD     0
CONSTANT: SHUT_WR     1
CONSTANT: SHUT_RDWR   2

LIBRARY: libc

STRUCT: group
    { gr_name c-string }
    { gr_passwd c-string }
    { gr_gid int }
    { gr_mem c-string* } ;

STRUCT: protoent
    { name c-string }
    { aliases void* }
    { proto int } ;

STRUCT: iovec
    { iov_base void* }
    { iov_len size_t } ;

STRUCT: servent
    { name c-string }
    { aliases void* }
    { port int }
    { proto c-string } ;

CONSTANT: F_OK 0 ! test for existence of file
CONSTANT: X_OK 1 ! test for execute or search permission
CONSTANT: W_OK 2 ! test for write permission
CONSTANT: R_OK 4 ! test for read permission

FUNCTION: int accept ( int s, void* sockaddr, socklen_t* socklen )
FUNCTION: int access ( c-string path, int amode )
FUNCTION: int bind ( int s, void* name, socklen_t namelen )
FUNCTION: int chdir ( c-string path )
FUNCTION: int chmod ( c-string path, mode_t mode )
FUNCTION: int fchmod ( int fd, mode_t mode )
FUNCTION: int chown ( c-string path, uid_t owner, gid_t group )
FUNCTION: int chroot ( c-string path )
FUNCTION: int close ( int fd )
FUNCTION: int closedir ( DIR* dirp )
FUNCTION: int connect ( int s, void* name, socklen_t namelen )
FUNCTION: int dup2 ( int oldd, int newd )
FUNCTION: void endpwent ( )
FUNCTION: int fchdir ( int fd )
FUNCTION: int fchown ( int fd, uid_t owner, gid_t group )
FUNCTION: int fcntl ( int fd, int cmd, int arg )
FUNCTION: int fileno ( FILE* stream )
FUNCTION: int flock ( int fd, int operation )
FUNCTION: void freeaddrinfo ( addrinfo* ai )
FUNCTION: int futimes ( int id, timeval[2] times )
FUNCTION: c-string gai_strerror ( int ecode )
FUNCTION: int getaddrinfo ( c-string hostname, c-string servname, addrinfo* hints, addrinfo** res )
FUNCTION: c-string getcwd ( c-string buf, size_t size )
FUNCTION: pid_t getpid ( )
FUNCTION: int getdtablesize ( )
FUNCTION: pid_t getpgrp ( )
FUNCTION: pid_t getpgid ( pid_t pid )
FUNCTION: gid_t getegid ( )
FUNCTION: uid_t geteuid ( )
FUNCTION: gid_t getgid ( )
FUNCTION: c-string getenv ( c-string name )

FUNCTION: int getgrgid_r ( gid_t gid, group* grp, c-string buffer, size_t bufsize, group** result )
FUNCTION: int getgrnam_r ( c-string name, group* grp, c-string buffer, size_t bufsize, group** result )
FUNCTION: passwd* getpwent ( )
FUNCTION: int killpg ( pid_t pgrp, int sig )
FUNCTION: void setpwent ( )
FUNCTION: void setpassent ( int stayopen )
FUNCTION: passwd* getpwuid ( uid_t uid )
FUNCTION: passwd* getpwnam ( c-string login )
FUNCTION: int getpwnam_r ( c-string login, passwd* pwd, c-string buffer, size_t bufsize, passwd** result )
FUNCTION: int getgroups ( int gidsetlen, gid_t* gidset )
FUNCTION: int getgrouplist ( c-string name, int basegid, int* groups, int* ngroups )
FUNCTION: int getrlimit ( int resource, rlimit* rlp )
FUNCTION: int setrlimit ( int resource, rlimit* rlp )
FUNCTION: int getpriority ( int which, id_t who )
FUNCTION: int setpriority ( int which, id_t who, int prio )
FUNCTION: int getrusage ( int who, rusage* r_usage )
FUNCTION: group* getgrent ( )
FUNCTION: void endgrent ( )
FUNCTION: int gethostname ( c-string name, int len )
FUNCTION: int getsockname ( int socket, sockaddr* address, socklen_t* address_len )
FUNCTION: int getpeername ( int socket, sockaddr* address, socklen_t* address_len )
FUNCTION: protoent* getprotobyname ( c-string name )
FUNCTION: servent* getservbyname ( c-string name, c-string proto )
FUNCTION: servent* getservbyport ( int port, c-string proto )
FUNCTION: uid_t getuid ( )
FUNCTION: uint htonl ( uint n )
FUNCTION: ushort htons ( ushort n )
! FUNCTION: int issetugid ;
FUNCTION: int isatty ( int fildes )
FUNCTION: int ioctl ( int fd, ulong request, void* argp )
FUNCTION: int lchown ( c-string path, uid_t owner, gid_t group )
FUNCTION: int listen ( int s, int backlog )
FUNCTION: off_t lseek ( int fildes, off_t offset, int whence )
FUNCTION: int mkdir ( c-string path, mode_t mode )
FUNCTION: int mkfifo ( c-string path, mode_t mode )
FUNCTION: void* mmap ( void* addr, size_t len, int prot, int flags, int fd, off_t offset )
FUNCTION: int munmap ( void* addr, size_t len )
FUNCTION: uint ntohl ( uint n )
FUNCTION: ushort ntohs ( ushort n )
FUNCTION: int shutdown ( int fd, int how )
FUNCTION: int open ( c-string path, int flags, int prot )
FUNCTION: DIR* opendir ( c-string path )

STRUCT: utimbuf
    { actime time_t }
    { modtime time_t } ;

FUNCTION: int utime ( c-string path, utimbuf* buf )

FUNCTION: int pclose ( void* file )
FUNCTION: int pipe ( int* filedes )
FUNCTION: void* popen ( c-string command, c-string type )
FUNCTION: ssize_t read ( int fd, void* buf, size_t nbytes )
FUNCTION: ssize_t readv ( int fd, iovec* iov, int iovcnt )

FUNCTION: dirent* readdir ( DIR* dirp )
FUNCTION: int readdir_r ( void* dirp, dirent* entry, dirent** result )
FUNCTION: ssize_t readlink ( c-string path, c-string buf, size_t bufsize )

CONSTANT: PATH_MAX 1024

FUNCTION: ssize_t recv ( int s, void* buf, size_t nbytes, int flags )
FUNCTION: ssize_t recvfrom ( int s, void* buf, size_t nbytes, int flags, sockaddr-in* from, socklen_t* fromlen )
FUNCTION: int rename ( c-string from, c-string to )
FUNCTION: int rmdir ( c-string path )
FUNCTION: int select ( int nfds, void* readfds, void* writefds, void* exceptfds, timeval* timeout )
FUNCTION: ssize_t sendto ( int s, void* buf, size_t len, int flags, sockaddr-in* to, socklen_t tolen )

FUNCTION: int setenv ( c-string name, c-string value, int overwrite )
FUNCTION: int unsetenv ( c-string name )
FUNCTION: int setegid ( gid_t egid )
FUNCTION: int seteuid ( uid_t euid )
FUNCTION: int setgid ( gid_t gid )
FUNCTION: int setgroups ( int ngroups, gid_t* gidset )
FUNCTION: int setpgid ( pid_t pid, pid_t gid )
FUNCTION: int setregid ( gid_t rgid, gid_t egid )
FUNCTION: int setreuid ( uid_t ruid, uid_t euid )
FUNCTION: pid_t setsid ( )
FUNCTION: int getsockopt ( int s, int level, int optname, void* optval, socklen_t* optlen )
FUNCTION: int setsockopt ( int s, int level, int optname, void* optval, socklen_t optlen )
FUNCTION: int setuid ( uid_t uid )
FUNCTION: int socket ( int domain, int type, int protocol )
FUNCTION: int symlink ( c-string path1, c-string path2 )
FUNCTION: int link ( c-string path1, c-string path2 )
FUNCTION: int ftruncate ( int fd, int length )
FUNCTION: int truncate ( c-string path, int length )
FUNCTION: int unlink ( c-string path )
FUNCTION: int utimes ( c-string path, timeval[2] times )
FUNCTION: ssize_t write ( int fd, void* buf, size_t nbytes )
FUNCTION: ssize_t writev ( int fds, iovec* iov, int iovcnt )
TYPEDEF: void* sighandler_t
FUNCTION: sighandler_t signal ( int signum, sighandler_t handler )

"librt" "librt.so" cdecl add-library
