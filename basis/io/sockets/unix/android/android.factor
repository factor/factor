USING: accessors byte-arrays io.encodings.string
io.encodings.utf8 io.pathnames io.sockets io.sockets.private kernel
math sequences unix.ffi ;
IN: io.sockets.unix.android

! Android's SELinux policy does not permit the shell or application domains
! to bind pathname sockets in otherwise writable directories.  The Linux
! abstract namespace is the platform's normal local-socket namespace.
M: local make-sockaddr
    path>> absolute-path utf8 encode
    dup length max-un-path 1 - > [ "Path too long" throw ] when
    B{ 0 } prepend max-un-path 0 pad-tail
    sockaddr-un new
        AF_UNIX >>family
        swap >>path init-sockaddr ;

M: local parse-sockaddr
    drop path>> >byte-array
    rest [ zero? ] trim-tail utf8 decode <local> ;
