USING: io.unix.backend io.unix.files io.unix.sockets io.timeouts
io.unix.launcher io.unix.mmap io.backend combinators namespaces
system vocabs.loader ;

{
    { [ bsd? ] [ "io.unix.bsd" ] }
    { [ macosx? ] [ "io.unix.bsd" ] }
    { [ linux? ] [ "io.unix.linux" ] }
    { [ solaris? ] [ "io.unix.solaris" ] }
} cond require
