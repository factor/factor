! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings io.backend io.nonblocking io.streams.duplex
io splitting sequences sequences.lib namespaces kernel
destructors math concurrency.combinators locals accessors
arrays continuations ;
IN: io.pipes

TUPLE: pipe in out ;

M: pipe dispose ( pipe -- )
    [ in>> close-handle ] [ out>> close-handle ] bi ;

HOOK: (pipe) io-backend ( -- pipe )

:: <pipe> ( encoding -- input-stream output-stream )
    [
        (pipe)
        [ add-error-destructor ]
        [ in>> <reader> encoding <decoder> ]
        [ out>> <writer> encoding <encoder> ]
        tri
    ] with-destructors ;

:: with-fds ( input-fd output-fd quot encoding -- )
    input-fd [ <reader> encoding <decoder> dup add-always-destructor ] [ input-stream get ] if* [
        output-fd [ <writer> encoding <encoder> dup add-always-destructor ] [ output-stream get ] if*
        quot with-output-stream*
    ] with-input-stream* ; inline

: <pipes> ( n -- pipes )
    [ (pipe) dup add-error-destructor ] replicate
    f f pipe boa [ prefix ] [ suffix ] bi
    2 <sliding-groups> ;

: with-pipe-fds ( seq -- results )
    [
        [ length dup zero? [ drop { } ] [ 1- <pipes> ] if ] keep
        [ >r [ first in>> ] [ second out>> ] bi r> 2curry ] 2map
        [ call ] parallel-map
    ] with-destructors ;

: with-pipes ( seq encoding -- results )
    [ [ with-fds ] 2curry ] curry map with-pipe-fds ;
