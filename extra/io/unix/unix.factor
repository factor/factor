USING: accessors system words sequences vocabs.loader ;

{
    "io.unix.backend"
    "io.unix.files"
    "io.unix.sockets"
    "io.unix.sockets.secure"
    "io.unix.launcher"
    "io.unix.mmap"
    "io.unix.pipes"
} [ require ] each

"io.unix." os name>> append require
