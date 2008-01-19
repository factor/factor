USING: io.unix.backend io.unix.files io.unix.sockets
io.unix.launcher io.unix.mmap io.backend combinators namespaces
system vocabs.loader ;

{
    ! kqueue is a work in progress
    ! { [ macosx? ] [ "io.unix.backend.kqueue" ] }
    ! { [ bsd? ] [ "io.unix.backend.kqueue" ] }
    { [ unix? ] [ "io.unix.backend.select" ] }
} cond require

T{ unix-io } io-backend set-global
