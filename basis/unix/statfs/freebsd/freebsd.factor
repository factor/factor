! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.syntax alien.c-types unix.types unix.stat classes.struct ;
IN: unix.statfs.freebsd

CONSTANT: MFSNAMELEN      16            ! length of type name including null */
CONSTANT: MNAMELEN        1024            ! size of on/from name bufs
CONSTANT: STAFS_VERSION 0x20140518

STRUCT: statfs
    { f_version __uint32_t }
    { f_type __uint32_t }
    { f_flags __uint64_t }
    { f_bsize __uint64_t }
    { f_iosize __uint64_t }
    { f_blocks __uint64_t }
    { f_bfree __uint64_t }
    { f_bavail __int64_t }
    { f_files __uint64_t }
    { f_ffree __int64_t }
    { f_syncwrites __uint64_t }
    { f_asyncwrites __uint64_t }
    { f_syncreads __uint64_t }
    { f_asyncreads __uint64_t }
    { f_spare __uint64_t[10] }
    { f_namemax __uint32_t }
    { f_owner uid_t }
    { f_fsid fsid_t }
    { f_charspare char[80] }
    { f_fstypename { char MFSNAMELEN } }
    { f_mntfromname { char MNAMELEN } }
    { f_mntonname { char MNAMELEN } } ;

FUNCTION-ALIAS: statfs-func int statfs ( c-string path, statfs* buf ) 
CONSTANT: MNT_WAIT    1   ! synchronously wait for I/O to complete
CONSTANT: MNT_NOWAIT  2   ! start all I/O, but do not wait for it

