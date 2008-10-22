! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel unix ; 
IN: unix.statfs.openbsd.32

: MFSNAMELEN 16 ; inline
: MNAMELEN 90 ; inline

C-STRUCT: statfs
    { "u_int32_t"  "f_flags" }
    { "int32_t"    "f_bsize" }
    { "u_int32_t"  "f_iosize" }
    { "u_int32_t"  "f_blocks" }
    { "u_int32_t"  "f_bfree" }
    { "int32_t"    "f_bavail" }
    { "u_int32_t"  "f_files" }
    { "u_int32_t"  "f_ffree" }
    { "fsid_t"     "f_fsid" }
    { "uid_t"      "f_owner" }
    { "u_int32_t"  "f_syncwrites" }
    { "u_int32_t"  "f_asyncwrites" }
    { "u_int32_t"  "f_ctime" }
    { { "u_int32_t" 3 }  "f_spare" }
    { { "char" MFSNAMELEN } "f_fstypename" }
    { { "char" MNAMELEN }   "f_mntonname" }  
    { { "char" MNAMELEN }   "f_mntfromname" } ;
