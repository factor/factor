REQUIRES: library/windows library/io/buffer ;

PROVIDE: library/io/windows
{ +files+ {
    "errors.factor"
    "io-internals.factor"
    "stream.factor"
    "server.factor"
    "io.factor"
} } ;
