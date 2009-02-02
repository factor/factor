! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations destructors io io.encodings
io.encodings.private io.timeouts io.ports summary
accessors delegate delegate.protocols ;
IN: io.streams.duplex

TUPLE: duplex-stream in out ;

C: <duplex-stream> duplex-stream

CONSULT: input-stream-protocol duplex-stream in>> ;

CONSULT: output-stream-protocol duplex-stream out>> ;

M: duplex-stream set-timeout
    [ in>> set-timeout ] [ out>> set-timeout ] 2bi ;

M: duplex-stream dispose
    #! The output stream is closed first, in case both streams
    #! are attached to the same file descriptor, the output
    #! buffer needs to be flushed before we close the fd.
    [
        [ in>> &dispose drop ]
        [ out>> &dispose drop ]
        bi
    ] with-destructors ;

: <encoder-duplex> ( stream-in stream-out encoding -- duplex )
    [ re-decode ] [ re-encode ] bi-curry bi* <duplex-stream> ;

: with-stream* ( stream quot -- )
    [ [ in>> ] [ out>> ] bi ] dip with-streams* ; inline

: with-stream ( stream quot -- )
    [ [ in>> ] [ out>> ] bi ] dip with-streams ; inline

ERROR: invalid-duplex-stream ;

M: duplex-stream underlying-handle
    [ in>> underlying-handle ]
    [ out>> underlying-handle ] bi
    [ = [ invalid-duplex-stream ] when ] keep ;

