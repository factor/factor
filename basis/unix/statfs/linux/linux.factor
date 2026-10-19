! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax arrays classes.parser classes.struct
kernel sequences system unix.types unix.stat vocabs ;
IN: unix.statfs.linux

<<
"statfs64" create-class-in
cpu mips? [
    {
        { "f_type" long }
        { "f_bsize" long }
        { "f_frsize" long }
        { "f_blocks" ulonglong }
        { "f_bfree" ulonglong }
        { "f_files" ulonglong }
        { "f_ffree" ulonglong }
        { "f_bavail" ulonglong }
        { "f_fsid" __fsid_t }
        { "f_namelen" long }
        { "f_flags" long }
        { "f_spare" { long 5 } }
    }
] [
    {
        { "f_type" __SWORD_TYPE }
        { "f_bsize" __SWORD_TYPE }
        { "f_blocks" __fsblkcnt64_t }
        { "f_bfree" __fsblkcnt64_t }
        { "f_bavail" __fsblkcnt64_t }
        { "f_files" __fsblkcnt64_t }
        { "f_ffree" __fsblkcnt64_t }
        { "f_fsid" __fsid_t }
        { "f_namelen" __SWORD_TYPE }
        { "f_frsize" __SWORD_TYPE }
        { "f_flags" __SWORD_TYPE }
        { "f_spare" { __SWORD_TYPE 4 } }
    }
] if [ first2 f <struct-slot-spec> ] map define-struct-class
>>

FUNCTION: int statfs64 ( c-string path, statfs64* buf )

cpu x86.64? [ "unix.statfs.linux.x86.64" require ] when
