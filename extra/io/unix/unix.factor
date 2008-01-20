USING: io.unix.backend io.unix.files io.unix.sockets
io.unix.launcher io.unix.mmap io.backend combinators namespaces
system vocabs.loader ;

{
    { [ bsd? ] [ "io.unix.bsd" ] }
    { [ macosx? ] [ "io.unix.bsd" ] }
    { [ linux? ] [ "io.unix.backend.linux" ] }
    { [ solaris? ] [ "io.unix.backend.solaris" ] }
} cond require
