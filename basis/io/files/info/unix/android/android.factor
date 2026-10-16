USING: accessors combinators io.backend io.files.info.unix
io.files.info.unix.linux kernel libc system unix.statfs.android
unix.statfs.linux unix.statvfs.android ;
IN: io.files.info.unix.android

M: android mount-table-path "/proc/mounts" ;

M: android file-system-statfs
    \ statfs64 new [ android-statfs64 io-error ] keep ;

M: android file-system-statvfs
    \ statvfs64 new [ statvfs64 io-error ] keep ;

M: android statvfs>file-system-info
    {
        [ f_flag>> >>flags ]
        [ f_namemax>> >>name-max ]
    } cleave ;
