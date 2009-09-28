! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct unix.types ;
IN: unix.statvfs.openbsd

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

CONSTANT: ST_RDONLY       1
CONSTANT: ST_NOSUID       2

FUNCTION: int statvfs ( char* path, statvfs* buf ) ;
