! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types io.encodings.utf8 io.encodings.string
kernel sequences unix.stat accessors unix combinators math
grouping system unix.statfs io.files io.backend alien.strings
math.bitwise alien.syntax ;
IN: unix.statfs.macosx

: MNT_RDONLY  HEX: 00000001 ; inline
: MNT_SYNCHRONOUS HEX: 00000002 ; inline
: MNT_NOEXEC  HEX: 00000004 ; inline
: MNT_NOSUID  HEX: 00000008 ; inline
: MNT_NODEV   HEX: 00000010 ; inline
: MNT_UNION   HEX: 00000020 ; inline
: MNT_ASYNC   HEX: 00000040 ; inline
: MNT_EXPORTED HEX: 00000100 ; inline
: MNT_QUARANTINE  HEX: 00000400 ; inline
: MNT_LOCAL   HEX: 00001000 ; inline
: MNT_QUOTA   HEX: 00002000 ; inline
: MNT_ROOTFS  HEX: 00004000 ; inline
: MNT_DOVOLFS HEX: 00008000 ; inline
: MNT_DONTBROWSE  HEX: 00100000 ; inline
: MNT_IGNORE_OWNERSHIP HEX: 00200000 ; inline
: MNT_AUTOMOUNTED HEX: 00400000 ; inline
: MNT_JOURNALED   HEX: 00800000 ; inline
: MNT_NOUSERXATTR HEX: 01000000 ; inline
: MNT_DEFWRITE    HEX: 02000000 ; inline
: MNT_MULTILABEL  HEX: 04000000 ; inline
: MNT_NOATIME HEX: 10000000 ; inline
: MNT_UNKNOWNPERMISSIONS MNT_IGNORE_OWNERSHIP ; inline

: MNT_VISFLAGMASK ( -- n )
    {
        MNT_RDONLY MNT_SYNCHRONOUS MNT_NOEXEC
        MNT_NOSUID MNT_NODEV MNT_UNION
        MNT_ASYNC MNT_EXPORTED MNT_QUARANTINE
        MNT_LOCAL MNT_QUOTA
        MNT_ROOTFS MNT_DOVOLFS MNT_DONTBROWSE
        MNT_IGNORE_OWNERSHIP MNT_AUTOMOUNTED MNT_JOURNALED
        MNT_NOUSERXATTR MNT_DEFWRITE MNT_MULTILABEL MNT_NOATIME
    } flags ; inline

: MNT_UPDATE  HEX: 00010000 ; inline
: MNT_RELOAD  HEX: 00040000 ; inline
: MNT_FORCE   HEX: 00080000 ; inline
: MNT_CMDFLAGS { MNT_UPDATE MNT_RELOAD MNT_FORCE } flags ; inline

: VFS_GENERIC 0 ; inline
: VFS_NUMMNTOPS 1 ; inline
: VFS_MAXTYPENUM 1 ; inline
: VFS_CONF 2 ; inline
: VFS_SET_PACKAGE_EXTS 3 ; inline

: MNT_WAIT    1 ; inline
: MNT_NOWAIT  2 ; inline

: VFS_CTL_VERS1   HEX: 01 ; inline

: VFS_CTL_STATFS  HEX: 00010001 ; inline
: VFS_CTL_UMOUNT  HEX: 00010002 ; inline
: VFS_CTL_QUERY   HEX: 00010003 ; inline
: VFS_CTL_NEWADDR HEX: 00010004 ; inline
: VFS_CTL_TIMEO   HEX: 00010005 ; inline
: VFS_CTL_NOLOCKS HEX: 00010006 ; inline

C-STRUCT: vfsquery
    { "uint32_t" "vq_flags" }
    { { "uint32_t" 31 } "vq_spare" } ;

: VQ_NOTRESP  HEX: 0001 ; inline
: VQ_NEEDAUTH HEX: 0002 ; inline
: VQ_LOWDISK  HEX: 0004 ; inline
: VQ_MOUNT    HEX: 0008 ; inline
: VQ_UNMOUNT  HEX: 0010 ; inline
: VQ_DEAD     HEX: 0020 ; inline
: VQ_ASSIST   HEX: 0040 ; inline
: VQ_NOTRESPLOCK  HEX: 0080 ; inline
: VQ_UPDATE   HEX: 0100 ; inline
: VQ_FLAG0200 HEX: 0200 ; inline
: VQ_FLAG0400 HEX: 0400 ; inline
: VQ_FLAG0800 HEX: 0800 ; inline
: VQ_FLAG1000 HEX: 1000 ; inline
: VQ_FLAG2000 HEX: 2000 ; inline
: VQ_FLAG4000 HEX: 4000 ; inline
: VQ_FLAG8000 HEX: 8000 ; inline

: NFSV4_MAX_FH_SIZE 128 ; inline
: NFSV3_MAX_FH_SIZE 64 ; inline
: NFSV2_MAX_FH_SIZE 32 ; inline
: NFS_MAX_FH_SIZE NFSV4_MAX_FH_SIZE ; inline

: MFSNAMELEN 15 ; inline
: MNAMELEN 90 ; inline
: MFSTYPENAMELEN 16 ; inline

C-STRUCT: fsid_t
    { { "int32_t" 2 } "val" } ;

C-STRUCT: statfs64
    { "uint32_t"        "f_bsize" }
    { "int32_t"         "f_iosize" }
    { "uint64_t"        "f_blocks" }
    { "uint64_t"        "f_bfree" }
    { "uint64_t"        "f_bavail" }
    { "uint64_t"        "f_files" }
    { "uint64_t"        "f_ffree" }
    { "fsid_t"          "f_fsid" }
    { "uid_t"           "f_owner" }
    { "uint32_t"        "f_type" }
    { "uint32_t"        "f_flags" }
    { "uint32_t"        "f_fssubtype" }
    { { "char" MFSTYPENAMELEN } "f_fstypename" }
    { { "char" MAXPATHLEN } "f_mntonname" }
    { { "char" MAXPATHLEN } "f_mntfromname" }
    { { "uint32_t" 8 } "f_reserved" } ;

FUNCTION: int statfs64 ( char* path, statfs64* buf ) ;
FUNCTION: int getmntinfo64 ( statfs64** mntbufp, int flags ) ;


TUPLE: macosx-file-system-info < file-system-info
block-size io-size blocks blocks-free blocks-available files
files-free file-system-id owner type flags filesystem-subtype
file-system-type-name mount-from ;

M: macosx mounted ( -- array )
    f <void*> dup 0 getmntinfo64 dup io-error
    [ *void* ] dip
    "statfs64" heap-size [ * memory>byte-array ] keep group
    [ >file-system-info ] map ;

M: macosx >file-system-info ( byte-array -- file-system-info )
    [ \ macosx-file-system-info new ] dip
    {
        [
            [ statfs64-f_bavail ] [ statfs64-f_bsize ] bi *
            >>free-space
        ]
        [ statfs64-f_mntonname utf8 alien>string >>mount-on ]
        [ statfs64-f_bsize >>block-size ]

        [ statfs64-f_iosize >>io-size ]
        [ statfs64-f_blocks >>blocks ]
        [ statfs64-f_bfree >>blocks-free ]
        [ statfs64-f_bavail >>blocks-available ]
        [ statfs64-f_files >>files ]
        [ statfs64-f_ffree >>files-free ]
        [ statfs64-f_fsid >>file-system-id ]
        [ statfs64-f_owner >>owner ]
        [ statfs64-f_type >>type ]
        [ statfs64-f_flags >>flags ]
        [ statfs64-f_fssubtype >>filesystem-subtype ]
        [
            statfs64-f_fstypename utf8 alien>string
            >>file-system-type-name
        ]
        [
            statfs64-f_mntfromname
            utf8 alien>string >>mount-from
        ]
    } cleave ;

M: macosx file-system-info ( path -- file-system-info )
    normalize-path
    "statfs64" <c-object> tuck statfs64 io-error
    >file-system-info ;
