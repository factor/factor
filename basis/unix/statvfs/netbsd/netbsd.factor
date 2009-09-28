! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct unix.types
unix.stat ;
IN: unix.statvfs.netbsd

CONSTANT: _VFS_NAMELEN    32
CONSTANT: _VFS_MNAMELEN   1024

STRUCT: statvfs
    { f_flag ulong }
    { f_bsize ulong }
    { f_frsize ulong }
    { f_iosize ulong }
    { f_blocks fsblkcnt_t }
    { f_bfree fsblkcnt_t }
    { f_bavail fsblkcnt_t }
    { f_bresvd fsblkcnt_t }
    { f_files fsfilcnt_t }
    { f_ffree fsfilcnt_t }
    { f_favail fsfilcnt_t }
    { f_fresvd fsfilcnt_t }
    { f_syncreads uint64_t }
    { f_syncwrites uint64_t }
    { f_asyncreads uint64_t }
    { f_asyncwrites uint64_t }
    { f_fsidx fsid_t }
    { f_fsid ulong }
    { f_namemax ulong }
    { f_owner uid_t }
    { f_spare uint32_t[4] }
    { f_fstypename { "char" _VFS_NAMELEN } }
    { f_mntonname { "char" _VFS_MNAMELEN } }
    { f_mntfromname { "char" _VFS_MNAMELEN } } ;

FUNCTION: int statvfs ( char* path, statvfs* buf ) ;
