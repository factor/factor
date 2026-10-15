USING: alien.c-types alien.syntax classes.struct unix.types ;
IN: unix.statvfs.haiku
STRUCT: statvfs
    { f_bsize ulong } { f_frsize ulong } { f_blocks fsblkcnt_t }
    { f_bfree fsblkcnt_t } { f_bavail fsblkcnt_t } { f_files fsfilcnt_t }
    { f_ffree fsfilcnt_t } { f_favail fsfilcnt_t } { f_fsid ulong }
    { f_flag ulong } { f_namemax ulong } ;
FUNCTION-ALIAS: statvfs-func int statvfs ( c-string path, statvfs* buffer )
