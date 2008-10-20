USING: kernel alien.syntax math sequences unix
alien.c-types arrays accessors combinators ;

IN: unix.stat

! Ubuntu 7.10 64-bit

C-STRUCT: stat
    { "dev_t"     "st_dev" }
    { "ino_t"     "st_ino" }
    { "nlink_t"   "st_nlink" }
    { "mode_t"    "st_mode" }
    { "uid_t"     "st_uid" }
    { "gid_t"     "st_gid" }
    { "int"       "pad0" }
    { "dev_t"     "st_rdev" }
    { "off_t"     "st_size" }
    { "blksize_t" "st_blksize" }
    { "blkcnt_t"  "st_blocks" }
    { "timespec"  "st_atimespec" }
    { "timespec"  "st_mtimespec" }
    { "timespec"  "st_ctimespec" }
    { "long"      "__unused0" }
    { "long"      "__unused1" }
    { "long"      "__unused2" } ;

FUNCTION: int __xstat  ( int ver, char* pathname, stat* buf ) ;
FUNCTION: int __lxstat ( int ver, char* pathname, stat* buf ) ;

:  stat ( pathname buf -- int ) 1 -rot __xstat ;
: lstat ( pathname buf -- int ) 1 -rot __lxstat ;

C-STRUCT: fstab
    { "char*" "fs_spec" }
    { "char*" "fs_file" }
    { "char*" "fs_vfstype" }
    { "char*" "fs_mntops" }
    { "char*" "fs_type" }
    { "int" "fs_freq" }
    { "int" "fs_passno" } ;

FUNCTION: fstab* getfsent ( ) ;
FUNCTION: fstab* getfsspec ( char* name ) ;
FUNCTION: fstab* getfsfile ( char* name ) ;
FUNCTION: int setfsent ( ) ;
FUNCTION: void endfsent ( ) ;

TUPLE: fstab spec file vfstype mntops type freq passno ;

: fstab-struct>fstab ( struct -- fstab )
    [ fstab new ] dip
    {
        [ fstab-fs_spec >>spec ]
        [ fstab-fs_file >>file ]
        [ fstab-fs_vfstype >>vfstype ]
        [ fstab-fs_mntops >>mntops ]
        [ fstab-fs_type >>type ]
        [ fstab-fs_freq >>freq ]
        [ fstab-fs_passno >>passno ]
    } cleave ;

C-STRUCT: fsid
    { { "int" 2 } "__val" } ;

TYPEDEF: fsid __fsid_t

TYPEDEF: ssize_t __SWORD_TYPE
TYPEDEF: ulonglong __fsblkcnt64_t
TYPEDEF: ulonglong __fsfilcnt64_t

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

TUPLE: statfs type bsize blocks bfree bavail files ffree fsid
namelen frsize spare ;

: statfs-struct>statfs ( struct -- statfs )
    [ \ statfs new ] dip
    {
        [ statfs64-f_type >>type ]
        [ statfs64-f_bsize >>bsize ]
        [ statfs64-f_blocks >>blocks ]
        [ statfs64-f_bfree >>bfree ]
        [ statfs64-f_bavail >>bavail ]
        [ statfs64-f_files >>files ]
        [ statfs64-f_ffree >>ffree ]
        [ statfs64-f_fsid >>fsid ]
        [ statfs64-f_namelen >>namelen ]
        [ statfs64-f_frsize >>frsize ]
        [ statfs64-f_spare >>spare ]
    } cleave ;

FUNCTION: int statfs64 ( char* path, statfs64* buf ) ;
: statfs ( path -- byte-array )
    "statfs64" <c-object> [ statfs64 io-error ] keep ;

: all-fstabs ( -- seq )
    setfsent io-error
    [ getfsent dup ] [ fstab-struct>fstab ] [ drop ] produce endfsent ;

C-STRUCT: mntent
    { "char*" "mnt_fsname" }
    { "char*" "mnt_dir" }
    { "char*" "mnt_type" }
    { "char*" "mnt_opts" }
    { "int" "mnt_freq" }
    { "int" "mnt_passno" } ;

