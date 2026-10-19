USING: alien.c-types alien.syntax classes.struct kernel unix.types ;
IN: unix.statvfs.android

STRUCT: statvfs64
    { f_bsize ulong }
    { f_frsize ulong }
    { f_blocks __fsblkcnt64_t }
    { f_bfree __fsblkcnt64_t }
    { f_bavail __fsblkcnt64_t }
    { f_files __fsfilcnt64_t }
    { f_ffree __fsfilcnt64_t }
    { f_favail __fsfilcnt64_t }
    { f_fsid ulong }
    { f_flag ulong }
    { f_namemax ulong }
    { __f_reserved uint[6] } ;

FUNCTION-ALIAS: statvfs64 int statvfs ( c-string path, statvfs64* buf )

CONSTANT: ST_RDONLY 1
CONSTANT: ST_NOSUID 2
CONSTANT: ST_NODEV 4
CONSTANT: ST_NOEXEC 8
CONSTANT: ST_SYNCHRONOUS 16
CONSTANT: ST_MANDLOCK 64
CONSTANT: ST_NOATIME 1024
