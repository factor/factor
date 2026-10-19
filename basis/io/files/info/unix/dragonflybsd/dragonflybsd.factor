USING: accessors classes.struct combinators io.files.info io.files.info.unix
    io.launcher kernel math math.bitwise sequences splitting system libc unix.statvfs.dragonflybsd ;
IN: io.files.info.unix.dragonflybsd

! DragonFly access(X_OK) succeeds for root even when execve would reject
! a regular file with no execute bits. Directory search keeps native access.
M: dragonflybsd file-executable?
    [ call-next-method ] [
        dup directory? [ drop t ] [
            file-info permissions>> 0o111 bitand 0 >
        ] if
    ] bi and ;

M: dragonflybsd file-system-statvfs
    \ statvfs new [ statvfs-func io-error ] keep ;

M: dragonflybsd statvfs>file-system-info
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

M: dragonflybsd file-systems
    "/sbin/mount" process-lines
    [ " on " split1 nip " (" split1 drop file-system-info ] map ;
