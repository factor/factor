USING: compiler.units definitions io.backend io.streams.c kernel
math threads.private vocabs ;

[
    c-io-backend forget
    "io.streams.c" forget-vocab
] with-compilation-unit

M: object io-multiplex
    dup 0 = [ drop ] [ 60 60 * 1000 * 1000 * or (sleep) ] if ;
