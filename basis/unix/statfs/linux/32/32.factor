! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax unix.types ;
IN: unix.statfs.linux

C-STRUCT: statfs
    { "long"    "f_type" }
    { "long"    "f_bsize" }
    { "long"    "f_blocks" }
    { "long"    "f_bfree" }
    { "long"    "f_bavail" }
    { "long"    "f_files" }
    { "long"    "f_ffree" }
    { "fsid_t"  "f_fsid" }
    { "long"    "f_namelen" } ;
