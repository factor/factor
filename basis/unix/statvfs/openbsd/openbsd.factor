USING: alien.c-types alien.syntax classes.struct unix.types ;
IN: unix.statvfs.openbsd

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
    ;

FUNCTION-ALIAS: statvfs-func int statvfs ( c-string path, statvfs* buf )
