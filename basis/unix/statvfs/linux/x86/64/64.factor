USING: alien.c-types alien.syntax ;
IN: unix.statvfs.linux

LIBRARY: libc

! On x86-64 the native statvfs layout is also the wide layout.
FUNCTION-ALIAS: statvfs64 int statvfs ( c-string path, statvfs64* buf )
