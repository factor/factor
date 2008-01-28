USING: alien.c-types byte-arrays combinators hexdump io
io.backend io.streams.string io.sockets.headers kernel math
prettyprint io.sniffer sequences system vocabs.loader
io.sniffer.filter.backend ;
IN: io.sniffer.filter


bsd? [ "io.sniffer.filter.bsd" require ] when
