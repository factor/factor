USING: accessors calendar.unix classes.struct combinators io.files.info io.files.info.unix
    io.files.info.unix.bsd unix.stat
    io.launcher kernel sequences splitting system libc unix.statvfs.netbsd ;
IN: io.files.info.unix.netbsd

M: netbsd stat>birth-time st_birthtimespec>> timespec>unix-time ;

M: netbsd file-system-statvfs
    \ statvfs new [ statvfs-func io-error ] keep ;

M: netbsd statvfs>file-system-info
    {
        [ f_frsize>> >>block-size ]
        [ f_bsize>> >>preferred-block-size ]
        [ f_blocks>> >>blocks ]
        [ f_bfree>> >>blocks-free ]
        [ f_bavail>> >>blocks-available ]
        [ f_files>> >>files ]
        [ f_ffree>> >>files-free ]
        [ f_favail>> >>files-available ]
        [ f_flag>> >>flags ]
        [ f_fsid>> >>id ]
        [ f_namemax>> >>name-max ]
    } cleave ;

M: netbsd file-systems
    "/sbin/mount" process-lines
    [ " on " split1 nip " type " split1 drop file-system-info ] map ;
