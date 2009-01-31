! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax ;
IN: unix.statvfs.openbsd

C-STRUCT: statvfs
    { "ulong" "f_bsize" }
    { "ulong" "f_frsize" }
    { "fsblkcnt_t" "f_blocks" }
    { "fsblkcnt_t" "f_bfree" }
    { "fsblkcnt_t" "f_bavail" }
    { "fsfilcnt_t" "f_files" }
    { "fsfilcnt_t" "f_ffree" }
    { "fsfilcnt_t" "f_favail" }
    { "ulong" "f_fsid" }
    { "ulong" "f_flag" }
    { "ulong" "f_namemax" } ;

CONSTANT: ST_RDONLY       1
CONSTANT: ST_NOSUID       2

FUNCTION: int statvfs ( char* path, statvfs* buf ) ;
