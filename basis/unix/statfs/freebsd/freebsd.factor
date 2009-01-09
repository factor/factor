! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax unix.types unix.stat ;
IN: unix.statfs.freebsd

CONSTANT: MFSNAMELEN      16            ! length of type name including null */
CONSTANT: MNAMELEN        88            ! size of on/from name bufs
CONSTANT: STATFS_VERSION  HEX: 20030518 ! current version number 

C-STRUCT: statfs
    { "uint32_t" "f_version" }
    { "uint32_t" "f_type" }
    { "uint64_t" "f_flags" }
    { "uint64_t" "f_bsize" }
    { "uint64_t" "f_iosize" }
    { "uint64_t" "f_blocks" }
    { "uint64_t" "f_bfree" }
    { "int64_t"  "f_bavail" }
    { "uint64_t" "f_files" }
    { "int64_t"  "f_ffree" }
    { "uint64_t" "f_syncwrites" }
    { "uint64_t" "f_asyncwrites" }
    { "uint64_t" "f_syncreads" }
    { "uint64_t" "f_asyncreads" }
    { { "uint64_t" 10 } "f_spare" }
    { "uint32_t" "f_namemax" }
    { "uid_t"    "f_owner" }
    { "fsid_t"   "f_fsid" }
    { { "char" 80 } "f_charspare" }
    { { "char" MFSNAMELEN } "f_fstypename" }
    { { "char" MNAMELEN } "f_mntfromname" }
    { { "char" MNAMELEN } "f_mntonname" } ;

FUNCTION: int statfs ( char* path, statvfs* buf ) ;
