USING: accessors classes.struct combinators io.files.info
io.files.info.unix io.launcher kernel sequences splitting system libc
unix.statvfs.illumos ;
IN: io.files.info.unix.illumos

M: illumos file-system-statvfs
    \ statvfs new [ statvfs-func io-error ] keep ;

M: illumos statvfs>file-system-info
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

M: illumos file-systems
    "/sbin/mount" process-lines
    [ " on " split1 drop file-system-info ] map ;
