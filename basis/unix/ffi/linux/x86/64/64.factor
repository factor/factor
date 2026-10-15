USING: alien.c-types alien.syntax unix.types ;
IN: unix.ffi

LIBRARY: libc

! Native x86-64 offsets and directory entries are already 64-bit.
! Current musl exports the standard names without the LFS64 aliases.
FUNCTION-ALIAS: open64 int open ( c-string path, int flags, ... int prot )
FUNCTION-ALIAS: readdir64 dirent* readdir ( DIR* dirp )
FUNCTION-ALIAS: readdir64_r int readdir_r ( void* dirp, dirent* entry, dirent** result )
