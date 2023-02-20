! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors delegate delegate.protocols destructors effects
io io.encodings io.ports io.styles io.timeouts kernel ;
IN: io.streams.duplex

TUPLE: duplex-stream in out ;

C: <duplex-stream> duplex-stream

CONSULT: input-stream-protocol duplex-stream in>> ;
CONSULT: output-stream-protocol duplex-stream out>> ;
CONSULT: formatted-output-stream-protocol duplex-stream out>> ;

INSTANCE: duplex-stream input-stream
INSTANCE: duplex-stream output-stream

: >duplex-stream< ( stream -- in out ) [ in>> ] [ out>> ] bi ; inline

M: duplex-stream stream-element-type
    >duplex-stream<
    [ stream-element-type ] bi@
    2dup eq? [ drop ] [ "Cannot determine element type" throw ] if ;

M: duplex-stream set-timeout
    >duplex-stream< [ set-timeout ] bi-curry@ bi ;

M: duplex-stream dispose
    ! The output stream is closed first, in case both streams
    ! are attached to the same file descriptor, the output
    ! buffer needs to be flushed before we close the fd.
    [ >duplex-stream< [ &dispose drop ] bi@ ] with-destructors ;

: <encoder-duplex> ( stream-in stream-out encoding -- duplex )
    [ re-decode ] [ re-encode ] bi-curry bi* <duplex-stream> ;

: with-stream* ( stream quot -- )
    [ >duplex-stream< ] dip with-streams* ; inline

: with-stream ( stream quot -- )
    [ >duplex-stream< ] dip with-streams ; inline

ERROR: invalid-duplex-stream ;

M: duplex-stream underlying-handle
    >duplex-stream<
    [ underlying-handle ] bi@
    [ = [ invalid-duplex-stream ] when ] keep ;
