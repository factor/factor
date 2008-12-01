! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel unix math accessors
combinators system io.backend alien.c-types unix.statfs 
io.files ;
IN: unix.statfs.freebsd

: ST_RDONLY       1 ; inline
: ST_NOSUID       2 ; inline

C-STRUCT: statvfs               
    { "fsblkcnt_t" "f_bavail" }
    { "fsblkcnt_t" "f_bfree" }
    { "fsblkcnt_t" "f_blocks" }
    { "fsfilcnt_t" "f_favail" }
    { "fsfilcnt_t" "f_ffree" }
    { "fsfilcnt_t" "f_files" }
    { "ulong" "f_bsize" }
    { "ulong" "f_flag" }
    { "ulong" "f_frsize" }
    { "ulong" "f_fsid" }
    { "ulong" "f_namemax" } ;

FUNCTION: int statvfs ( char* path, statvfs* buf ) ;
