USING: io.unix.backend io.unix.files io.unix.sockets
io.unix.launcher io.unix.mmap io.unix.pipes io.timeouts
io.backend combinators namespaces system vocabs.loader
sequences words init ;

"io.unix." os word-name append require
