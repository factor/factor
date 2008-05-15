! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations destructors io io.encodings
io.encodings.private io.timeouts debugger inspector listener
accessors delegate delegate.protocols ;
IN: io.streams.duplex

! We ensure that the stream can only be closed once, to preserve
! integrity of duplex I/O ports.

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
        [ out>> &dispose drop ]
        [ in>> &dispose drop ]
        bi
    ] with-destructors ;

: <encoder-duplex> ( stream-in stream-out encoding -- duplex )
    tuck re-encode >r re-decode r> <duplex-stream> ;

: with-stream* ( stream quot -- )
    >r [ in>> ] [ out>> ] bi r> with-streams* ; inline

: with-stream ( stream quot -- )
    >r [ in>> ] [ out>> ] bi r> with-streams ; inline
