USING: alien.c-types alien.syntax ;
IN: unix.statfs.linux

LIBRARY: libc

! On x86-64 the native statfs layout is also the wide layout.
FUNCTION-ALIAS: statfs64 int statfs ( c-string path, statfs64* buf )
