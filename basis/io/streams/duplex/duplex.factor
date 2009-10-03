! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations destructors io io.encodings
io.encodings.private io.timeouts io.ports io.styles summary
accessors delegate delegate.protocols ;
IN: io.streams.duplex

TUPLE: duplex-stream in out ;

C: <duplex-stream> duplex-stream

CONSULT: input-stream-protocol duplex-stream in>> ;
CONSULT: output-stream-protocol duplex-stream out>> ;
CONSULT: formatted-output-stream-protocol duplex-stream out>> ;

: >duplex-stream< ( stream -- in out ) [ in>> ] [ out>> ] bi ; inline

M: duplex-stream stream-element-type
    [ in>> ] [ out>> ] bi
    [ stream-element-type ] bi@
    2dup eq? [ drop ] [ "Cannot determine element type" throw ] if ;

M: duplex-stream set-timeout
    >duplex-stream< [ set-timeout ] bi-curry@ bi ;

M: duplex-stream dispose
    #! The output stream is closed first, in case both streams
    #! are attached to the same file descriptor, the output
    #! buffer needs to be flushed before we close the fd.
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
