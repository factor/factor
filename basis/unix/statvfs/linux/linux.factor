! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax ;
IN: unix.statvfs.linux

C-STRUCT: statvfs64
    { "ulong" "f_bsize" }
    { "ulong" "f_frsize" }
    { "__fsblkcnt64_t" "f_blocks" }
    { "__fsblkcnt64_t" "f_bfree" }
    { "__fsblkcnt64_t" "f_bavail" }
    { "__fsfilcnt64_t" "f_files" }
    { "__fsfilcnt64_t" "f_ffree" }
    { "__fsfilcnt64_t" "f_favail" }
    { "ulong" "f_fsid" }
    { "ulong" "f_flag" }
    { "ulong" f_namemax" }
    { { "int" 6 } "__f_spare" } ;

FUNCTION: int statvfs64 ( char* path, statvfs64* buf ) ;

: ST_RDONLY 1 ; inline        ! Mount read-only.
: ST_NOSUID 2 ; inline        ! Ignore suid and sgid bits.
: ST_NODEV 4 ; inline         ! Disallow access to device special files.
: ST_NOEXEC 8 ; inline        ! Disallow program execution.
: ST_SYNCHRONOUS 16 ; inline  ! Writes are synced at once.
: ST_MANDLOCK 64 ; inline     ! Allow mandatory locks on an FS.
: ST_WRITE 128 ; inline       ! Write on file/directory/symlink.
: ST_APPEND 256 ; inline      ! Append-only file.
: ST_IMMUTABLE 512 ; inline   ! Immutable file.
: ST_NOATIME 1024 ; inline    ! Do not update access times.
