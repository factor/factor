! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax unix.types unix.stat ;
IN: unix.statfs.openbsd

CONSTANT: MFSNAMELEN 16
CONSTANT: MNAMELEN 90

C-STRUCT: statfs
    { "u_int32_t"       "f_flags" }
    { "u_int32_t"       "f_bsize" }
    { "u_int32_t"       "f_iosize" }
    { "u_int64_t"       "f_blocks" }
    { "u_int64_t"       "f_bfree" }
    { "int64_t"         "f_bavail" }
    { "u_int64_t"       "f_files" }
    { "u_int64_t"       "f_ffree" }
    { "int64_t"         "f_favail" }
    { "u_int64_t"       "f_syncwrites" }
    { "u_int64_t"       "f_syncreads" }
    { "u_int64_t"       "f_asyncwrites" }
    { "u_int64_t"       "f_asyncreads" }
    { "fsid_t"          "f_fsid" }
    { "u_int32_t"       "f_namemax" }
    { "uid_t"           "f_owner" }
    { "u_int32_t"       "f_ctime" }
    { { "u_int32_t" 3 } "f_spare" }
    { { "char" MFSNAMELEN } "f_fstypename" }
    { { "char" MNAMELEN } "f_mntonname" }
    { { "char" MNAMELEN } "f_mntfromname" }
    { { "char" 160 } "mount_info" } ;

FUNCTION: int statfs ( char* path, statvfs* buf ) ;
