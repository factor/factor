! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings io.backend io.nonblocking io.streams.duplex
io splitting sequences sequences.lib namespaces kernel
destructors math concurrency.combinators accessors
arrays continuations quotations ;
IN: io.pipes

TUPLE: pipe in out ;

M: pipe dispose ( pipe -- )
    [ in>> close-handle ] [ out>> close-handle ] bi ;

HOOK: (pipe) io-backend ( -- pipe )

: <pipe> ( encoding -- stream )
    [
        >r (pipe)
        [ add-error-destructor ]
        [ in>> <reader> ]
        [ out>> <writer> ]
        tri
        r> <encoder-duplex>
    ] with-destructors ;

: with-fds ( input-fd output-fd quot -- )
    >r >r [ <reader> dup add-always-destructor ] [ input-stream get ] if* r> r> [
        >r [ <writer> dup add-always-destructor ] [ output-stream get ] if* r>
        with-output-stream*
    ] 2curry with-input-stream* ; inline

: <pipes> ( n -- pipes )
    [ (pipe) dup add-always-destructor ] replicate
    f f pipe boa [ prefix ] [ suffix ] bi
    2 <clumps> ;

: with-pipe-fds ( seq -- results )
    [
        [ length dup zero? [ drop { } ] [ 1- <pipes> ] if ] keep
        [ >r [ first in>> ] [ second out>> ] bi r> 2curry ] 2map
        [ call ] parallel-map
    ] with-destructors ;

GENERIC: pipeline-element-quot ( obj -- quot )

M: callable pipeline-element-quot
    [ with-fds ] curry ;

GENERIC: wait-for-pipeline-element ( obj -- result )

M: object wait-for-pipeline-element ;

: with-pipeline ( seq -- results )
    [ pipeline-element-quot ] map
    with-pipe-fds
    [ wait-for-pipeline-element ] map ;
