! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel ;
IN: unix.statfs.freebsd

: ST_RDONLY       1 ; inline
: ST_NOSUID       2 ; inline

C-STRUCT: statvfs               
	{ "fsblkcnt_t" "f_bavail" }
	{ "fsblkcnt_t" "f_bfree" }
	{ "fsblkcnt_t" "f_blocks" }
	{ "fsfilcnt_t" "f_favail" }
	{ "fsfilcnt_t" "f_ffree" }
	{ "fsfilcnt_t" "f_files" }
	{ "ulong" "f_bsize" }
	{ "ulong" "f_flag" }
	{ "ulong" "f_frsize" }
	{ "ulong" "f_fsid" }
	{ "ulong" "f_namemax" }	;


TUPLE: freebsd-file-system-info < file-system-info
bavail bfree blocks favail ffree ffiles
bsize flag frsize fsid namemax ;

: statfs>file-system-info ( struct -- statfs )
    [ \ freebsd-file-system-info new ] dip
    {
        [
            [ statfs64-f_bsize ]
            [ statfs64-f_bavail ] bi * >>free-space
        ]
        [ statfs64-f_bavail >>bavail ]
        [ statfs64-f_bfree >>bfree ]
        [ statfs64-f_blocks >>blocks ]
        [ statfs64-f_favail >>favail ]
        [ statfs64-f_ffree >>ffree ]
        [ statfs64-f_files >>files ]
        [ statfs64-f_bsize >>bsize ]
        [ statfs64-f_flag >>flag ]
        [ statfs64-f_frsize >>frsize ]
        [ statfs64-f_fsid >>fsid ]
        [ statfs64-f_namelen >>namelen ]
    } cleave ;

M: freebsd file-system-info ( path -- byte-array )
    normalize-path
    "statvfs" <c-object> tuck statvfs io-error
    statfs>file-system-info ;
