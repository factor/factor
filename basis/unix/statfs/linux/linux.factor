! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax unix.types unix.stat ;
IN: unix.statfs.linux

C-STRUCT: statfs64
    { "__SWORD_TYPE" "f_type" }
    { "__SWORD_TYPE" "f_bsize" }
    { "__fsblkcnt64_t" "f_blocks" }
    { "__fsblkcnt64_t" "f_bfree" }
    { "__fsblkcnt64_t" "f_bavail" }
    { "__fsfilcnt64_t" "f_files" }
    { "__fsfilcnt64_t" "f_ffree" }
    { "__fsid_t" "f_fsid" }
    { "__SWORD_TYPE" "f_namelen" }
    { "__SWORD_TYPE" "f_frsize" }
    { { "__SWORD_TYPE" 5 } "f_spare" } ;

FUNCTION: int statfs64 ( char* path, statfs64* buf ) ;
