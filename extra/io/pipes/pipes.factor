! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings io.backend io.ports io.streams.duplex
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
        [ in>> <input-port> ]
        [ out>> <output-port> ]
        tri
        r> <encoder-duplex>
    ] with-destructors ;

<PRIVATE

: ?reader [ <input-port> dup add-always-destructor ] [ input-stream get ] if* ;
: ?writer [ <output-port> dup add-always-destructor ] [ output-stream get ] if* ;

GENERIC: run-pipeline-element ( input-fd output-fd obj -- quot )

M: callable run-pipeline-element
    [
        >r [ ?reader ] [ ?writer ] bi*
        r> with-streams*
    ] with-destructors ;

: <pipes> ( n -- pipes )
    [
        [ (pipe) dup add-error-destructor ] replicate
        T{ pipe } [ prefix ] [ suffix ] bi
        2 <clumps>
    ] with-destructors ;

PRIVATE>

: run-pipeline ( seq -- results )
    [ length dup zero? [ drop { } ] [ 1- <pipes> ] if ] keep
    [
        >r [ first in>> ] [ second out>> ] bi
        r> run-pipeline-element
    ] 2parallel-map ;
