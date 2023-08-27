! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax unix.types unix.stat classes.struct ;
IN: unix.statfs.linux

STRUCT: statfs64
    { f_type __SWORD_TYPE }
    { f_bsize __SWORD_TYPE }
    { f_blocks __fsblkcnt64_t }
    { f_bfree __fsblkcnt64_t }
    { f_bavail __fsblkcnt64_t }
    { f_files __fsblkcnt64_t }
    { f_ffree __fsblkcnt64_t }
    { f_fsid __fsid_t }
    { f_namelen __SWORD_TYPE }
    { f_frsize __SWORD_TYPE }
    { f_spare __SWORD_TYPE[5] } ;

FUNCTION: int statfs64 ( c-string path, statfs64* buf )
