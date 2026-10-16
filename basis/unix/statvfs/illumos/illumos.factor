USING: alien.c-types alien.syntax classes.struct unix.types ;
IN: unix.statvfs.illumos

STRUCT: statvfs
    { f_bsize ulong }
    { f_frsize ulong }
    { f_blocks fsblkcnt_t }
    { f_bfree fsblkcnt_t }
    { f_bavail fsblkcnt_t }
    { f_files fsfilcnt_t }
    { f_ffree fsfilcnt_t }
    { f_favail fsfilcnt_t }
    { f_fsid ulong }
    { f_basetype char[16] }
    { f_flag ulong }
    { f_namemax ulong }
    { f_fstr char[32] } ;

CONSTANT: ST_RDONLY 1
CONSTANT: ST_NOSUID 2
FUNCTION-ALIAS: statvfs-func int statvfs ( c-string path, statvfs* buf )
