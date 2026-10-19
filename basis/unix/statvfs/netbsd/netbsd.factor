USING: alien.c-types alien.syntax classes.struct unix.types ;
IN: unix.statvfs.netbsd

STRUCT: statvfs
    { f_flag ulong }
    { f_bsize ulong }
    { f_frsize ulong }
    { f_iosize ulong }
    { f_blocks ulonglong }
    { f_bfree ulonglong }
    { f_bavail ulonglong }
    { f_bresvd ulonglong }
    { f_files ulonglong }
    { f_ffree ulonglong }
    { f_favail ulonglong }
    { f_fresvd ulonglong }
    { f_syncreads ulonglong }
    { f_syncwrites ulonglong }
    { f_asyncreads ulonglong }
    { f_asyncwrites ulonglong }
    { f_fsidx int[2] }
    { f_fsid ulong }
    { f_namemax ulong }
    { f_owner uid_t }
    { f_spare ulonglong[4] }
    { f_fstypename char[32] }
    { f_mntonname char[1024] }
    { f_mntfromname char[1024] }
    { f_mntfromlabel char[1024] }
    ;

FUNCTION-ALIAS: statvfs-func int __statvfs90 ( c-string path, statvfs* buf )
