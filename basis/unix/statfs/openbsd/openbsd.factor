! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax unix.types unix.stat classes.struct ;
IN: unix.statfs.openbsd

CONSTANT: MFSNAMELEN 16
CONSTANT: MNAMELEN 90

STRUCT: statfs
    { f_flags u_int32_t }
    { f_bsize u_int32_t }
    { f_iosize u_int32_t }
    { f_blocks u_int64_t }
    { f_bfree u_int64_t }
    { f_bavail int64_t }
    { f_files u_int64_t }
    { f_ffree u_int64_t }
    { f_favail int64_t }
    { f_syncwrites u_int64_t }
    { f_syncreads u_int64_t }
    { f_asyncwrites u_int64_t }
    { f_asyncreads u_int64_t }
    { f_fsid fsid_t }
    { f_namemax u_int32_t }
    { f_owner uid_t }
    { f_ctime u_int32_t }
    { f_spare u_int32_t[3] }
    { f_fstypename { char MFSNAMELEN } }
    { f_mntonname { char MNAMELEN } }
    { f_mntfromname { char MNAMELEN } }
    { mount_info char[160] } ;

FUNCTION: int statfs ( char* path, statvfs* buf ) ;
