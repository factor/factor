USING: alien.c-types alien.syntax classes.struct unix.ffi.linux unix.types ;
IN: unix.ffi

! Bionic puts ai_canonname before ai_addr.  Linux's glibc headers use the
! opposite order, so this needs its own class even though the two records
! have the same size.
STRUCT: android-addrinfo
    { flags int }
    { family int }
    { socktype int }
    { protocol int }
    { addrlen socklen_t }
    { canonname c-string }
    { addr void* }
    { next android-addrinfo* } ;

ALIAS: addrinfo android-addrinfo

! Bionic uses the BSD getaddrinfo error numbers.
CONSTANT: EAI_SYSTEM 11
CONSTANT: AI_NUMERICSERV 0x0008

! Bionic uses 64-bit offsets on both supported ABIs, but exports the
! standard POSIX names instead of glibc's LFS64 aliases.
FUNCTION-ALIAS: open64 int open ( c-string path, int flags, ... int prot )
FUNCTION-ALIAS: readdir64 dirent* readdir ( DIR* dirp )
FUNCTION-ALIAS: readdir64_r int readdir_r (
    void* dirp, dirent* entry, dirent** result )
