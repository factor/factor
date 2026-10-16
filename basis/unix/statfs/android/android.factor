USING: alien.c-types alien.syntax unix.statfs.linux ;
IN: unix.statfs.android

LIBRARY: libc

FUNCTION-ALIAS: android-statfs64 int statfs (
    c-string path, unix.statfs.linux:statfs64* buf )
