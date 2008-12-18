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
    { "ulong" "f_namemax" }
    { { "int" 6 } "__f_spare" } ;

FUNCTION: int statvfs64 ( char* path, statvfs64* buf ) ;

CONSTANT: ST_RDONLY 1        ! Mount read-only.
CONSTANT: ST_NOSUID 2        ! Ignore suid and sgid bits.
CONSTANT: ST_NODEV 4         ! Disallow access to device special files.
CONSTANT: ST_NOEXEC 8        ! Disallow program execution.
CONSTANT: ST_SYNCHRONOUS 16  ! Writes are synced at once.
CONSTANT: ST_MANDLOCK 64     ! Allow mandatory locks on an FS.
CONSTANT: ST_WRITE 128       ! Write on file/directory/symlink.
CONSTANT: ST_APPEND 256      ! Append-only file.
CONSTANT: ST_IMMUTABLE 512   ! Immutable file.
CONSTANT: ST_NOATIME 1024    ! Do not update access times.
