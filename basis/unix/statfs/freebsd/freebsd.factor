! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax alien.c-types unix.types unix.stat classes.struct ;
IN: unix.statfs.freebsd

CONSTANT: MFSNAMELEN      16            ! length of type name including null */
CONSTANT: MNAMELEN        1024            ! size of on/from name bufs
CONSTANT: STAFS_VERSION 0x20140518

STRUCT: statfs
    { f_version uint32_t }
    { f_type uint32_t }
    { f_flags uint64_t }
    { f_bsize uint64_t }
    { f_iosize uint64_t }
    { f_blocks uint64_t }
    { f_bfree uint64_t }
    { f_bavail int64_t }
    { f_files uint64_t }
    { f_ffree int64_t }
    { f_syncwrites uint64_t }
    { f_asyncwrites uint64_t }
    { f_syncreads uint64_t }
    { f_asyncreads uint64_t }
    { f_spare uint64_t[10] }
    { f_namemax uint32_t }
    { f_owner uid_t }
    { f_fsid fsid_t }
    { f_charspare char[80] }
    { f_fstypename { char MFSNAMELEN } }
    { f_mntfromname { char MNAMELEN } }
    { f_mntonname { char MNAMELEN } } ;

FUNCTION-ALIAS: statfs-func int statfs ( c-string path, statfs* buf ) 
CONSTANT: MNT_WAIT    1   ! synchronously wait for I/O to complete
CONSTANT: MNT_NOWAIT  2   ! start all I/O, but do not wait for it

