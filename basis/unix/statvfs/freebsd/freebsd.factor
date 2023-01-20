! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct unix.types ;
IN: unix.statvfs.freebsd

STRUCT: statvfs
    { f_bavail fsblkcnt_t }
    { f_bfree fsblkcnt_t }
    { f_blocks fsblkcnt_t }
    { f_favail fsfilcnt_t }
    { f_ffree fsfilcnt_t }
    { f_files fsfilcnt_t }
    { f_bsize ulong }
    { f_flag ulong }
    { f_frsize ulong }
    { f_fsid ulong }
    { f_namemax ulong } ;

! Flags
CONSTANT: ST_RDONLY   1 ! Read-only file system
CONSTANT: ST_NOSUID   2 ! Does not honor setuid/setgid

FUNCTION-ALIAS: statvfs-func int statvfs ( c-string path, statvfs* buf )

