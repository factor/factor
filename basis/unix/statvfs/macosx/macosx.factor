! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct unix.types ;
IN: unix.statvfs.macosx

STRUCT: statvfs
    { f_bsize ulong }
    { f_frsize ulong }
    { f_blocks fsblkcnt_t }
    { f_bfree fsblkcnt_t }
    { f_bavail fsblkcnt_t }
    { f_files fsfilcnt_t }
    { f_ffree fsfilcnt_t }
    { f_favail fsfilcnt_t }
    { f_fsid ulong }
    { f_flag ulong }
    { f_namemax ulong } ;

! Flags
CONSTANT: ST_RDONLY   HEX: 1 ! Read-only file system
CONSTANT: ST_NOSUID   HEX: 2 ! Does not honor setuid/setgid

FUNCTION: int statvfs ( char* path, statvfs* buf ) ;
