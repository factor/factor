USING: alien.c-types alien.syntax classes.struct unix.types ;
IN: unix.statvfs.dragonflybsd

STRUCT: statvfs
    { f_bsize ulong }
    { f_frsize ulong }
    { f_blocks ulonglong }
    { f_bfree ulonglong }
    { f_bavail ulonglong }
    { f_files ulonglong }
    { f_ffree ulonglong }
    { f_favail ulonglong }
    { f_fsid ulong }
    { f_flag ulong }
    { f_namemax ulong }
    { f_owner uid_t }
    { f_type uint }
    { f_syncreads ulonglong }
    { f_syncwrites ulonglong }
    { f_asyncreads ulonglong }
    { f_asyncwrites ulonglong }
    { f_fsid_uuid uint[4] }
    { f_uid_uuid uint[4] }
    ;

FUNCTION-ALIAS: statvfs-func int statvfs ( c-string path, statvfs* buf )
