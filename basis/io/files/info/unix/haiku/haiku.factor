USING: accessors alien.c-types alien.data alien.strings byte-arrays calendar.unix classes.struct combinators io.files.info
io.files.info.unix kernel libc math sequences system unix.fs-info.haiku unix.stat unix.statvfs.haiku ;
IN: io.files.info.unix.haiku
M: haiku stat>file-info
    [ call-next-method ] keep st_crtimespec>> timespec>unix-time >>created ;
M: haiku file-system-statvfs
    \ statvfs new [ statvfs-func io-error ] keep ;
M: haiku statvfs>file-system-info
    { [ f_frsize>> >>block-size ] [ f_bsize>> >>preferred-block-size ]
      [ f_blocks>> >>blocks ] [ f_bfree>> >>blocks-free ]
      [ f_bavail>> >>blocks-available ] [ f_files>> >>files ]
      [ f_ffree>> >>files-free ] [ f_favail>> >>files-available ]
      [ f_fsid>> >>id ] [ f_flag>> >>flags ] [ f_namemax>> >>name-max ] } cleave ;

: volume-mount-path ( device -- path )
    1024 <byte-array> [ 1024 factor_haiku_volume_path io-error ] keep
    alien>native-string ;
: device-fs-info ( device -- info )
    fs-info new [ fs_stat_dev io-error ] keep ;
M: haiku file-system-info
    [ call-next-method ] keep dev_for_path dup io-error
    [ volume-mount-path >>mount-point ]
    [ device-fs-info [ device-name>> alien>native-string >>device-name ]
      [ fsh-name>> alien>native-string >>type ] bi ] bi ;
M: haiku file-systems
    0 int <ref> '[ _ next_dev dup 0 >= ] [ ] produce nip
    [ volume-mount-path file-system-info ] map ;
