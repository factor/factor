! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io-internals
USING: alien errors kernel math namespaces ;

ALIAS: ulonglong off_t
ALIAS: long ssize_t
ALIAS: ulong size_t

BEGIN-STRUCT: stat
    FIELD: uint dev
    FIELD: uint ino
    FIELD: ushort mode
    FIELD: ushort nlink
    FIELD: uint uid
    FIELD: uint gid
    FIELD: uint rdev
    FIELD: ulong atime
    FIELD: ulong atimensec
    FIELD: ulong mtime
    FIELD: ulong mtimensec
    FIELD: ulong ctime
    FIELD: ulong ctimensec
    FIELD: off_t size
    FIELD: off_t blocks
    FIELD: uint blksize
    FIELD: uint flags
    FIELD: uint gen
    
    FIELD: uint padding
    FIELD: ulonglong padding
    FIELD: ulonglong padding
END-STRUCT

: S_IFMT OCT: 0170000 ; inline
: S_ISDIR ( m -- ? ) OCT: 0170000 bitand OCT: 0040000 = ; inline

: sys-stat ( path stat -- n )
    "int" "libc" "stat" [ "char*" "stat*" ] alien-invoke ;

: sys-opendir ( path -- dir* )
    "void*" "libc" "opendir" [ "char*" ] alien-invoke ;

BEGIN-STRUCT: dirent
    FIELD: uint fileno
    FIELD: ushort reclen
    FIELD: uchar type
    FIELD: uchar namlen
    FIELD: uchar256 name
END-STRUCT

: sys-readdir ( dir* -- dirent* )
    "dirent*" "libc" "readdir" [ "void*" ] alien-invoke ;

: sys-closedir ( dir* -- )
    "void" "libc" "closedir" [ "void*" ] alien-invoke ;

BEGIN-STRUCT: string-box
    FIELD: uchar256 value
END-STRUCT

: errno ( -- n )
    "int" "libc" "errno" alien-global ;

: strerror ( n -- str )
    "char*" "libc" "strerror" [ "int" ] alien-invoke ;

: sys-getcwd ( str len -- n )
    "int" "libc" "getcwd" [ "string-box*" "uint" ] alien-invoke ;

: O_RDONLY  HEX: 0000 ;
: O_WRONLY  HEX: 0001 ;
: O_RDWR    HEX: 0002 ;
: O_CREAT   HEX: 0200 ;
: O_TRUNC   HEX: 0400 ;

: sys-open ( path flags prot -- fd )
    "int" "libc" "open" [ "char*" "int" "int" ] alien-invoke ;

: sys-close ( fd -- )
    "void" "libc" "close" [ "int" ] alien-invoke ;

: sys-read ( fd buf nbytes -- n )
    "ssize_t" "libc" "read" [ "int" "void*" "size_t" ] alien-invoke ;

: sys-write ( fd buf nbytes -- n )
    "ssize_t" "libc" "write" [ "int" "void*" "size_t" ] alien-invoke ;

: MSG_OOB HEX: 1 ;

: sys-recv ( fd buf nbytes flags -- )
    "ssize_t" "libc" "read" [ "int" "void*" "size_t" "int" ] alien-invoke ;
