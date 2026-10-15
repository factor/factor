USING: alien.c-types alien.syntax classes.struct unix.types unix.ffi.bsd ;
IN: unix.ffi

FUNCTION: int getgrouplist ( c-string name, gid_t basegid, gid_t* groups, int* ngroups )
FUNCTION: int setgroups ( int ngroups, gid_t* gidset )

CONSTANT: AF_INET6 28
ALIAS: PF_INET6 AF_INET6
CONSTANT: FD_SETSIZE 1024

STRUCT: sockaddr
    { sa_len uchar }
    { sa_family uchar }
    { sa_data char[14] }
    ;

STRUCT: addrinfo
    { flags int }
    { family int }
    { socktype int }
    { protocol int }
    { addrlen socklen_t }
    { canonname c-string }
    { addr void* }
    { next addrinfo* }
    ;

STRUCT: dirent
    { d_fileno ino_t }
    { d_namlen ushort }
    { d_type uchar }
    { d_unused1 uchar }
    { d_unused2 uint }
    { d_name char[256] }
    ;

STRUCT: passwd
    { pw_name c-string }
    { pw_passwd c-string }
    { pw_uid uid_t }
    { pw_gid gid_t }
    { pw_change time_t }
    { pw_class c-string }
    { pw_gecos c-string }
    { pw_dir c-string }
    { pw_shell c-string }
    { pw_expire time_t }
    { pw_fields int } ;
