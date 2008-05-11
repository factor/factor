! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations io io.encodings io.encodings.private
io.timeouts debugger inspector listener accessors delegate
delegate.protocols ;
IN: io.streams.duplex

! We ensure that the stream can only be closed once, to preserve
! integrity of duplex I/O ports.

TUPLE: duplex-stream in out closed ;

: <duplex-stream> ( in out -- stream )
    f duplex-stream boa ;

ERROR: stream-closed-twice ;

M: stream-closed-twice summary
    drop "Attempt to perform I/O on closed stream" ;

<PRIVATE

: check-closed ( stream -- stream )
    dup closed>> [ stream-closed-twice ] when ; inline

: in ( duplex -- stream ) check-closed in>> ;

: out ( duplex -- stream ) check-closed out>> ;

PRIVATE>

CONSULT: input-stream-protocol duplex-stream in ;

CONSULT: output-stream-protocol duplex-stream out ;

M: duplex-stream set-timeout
    [ in set-timeout ] [ out set-timeout ] 2bi ;

M: duplex-stream dispose
    #! The output stream is closed first, in case both streams
    #! are attached to the same file descriptor, the output
    #! buffer needs to be flushed before we close the fd.
    dup closed>> [
        t >>closed
        [ dup out>> dispose ]
        [ dup in>> dispose ] [ ] cleanup
    ] unless drop ;

: <encoder-duplex> ( stream-in stream-out encoding -- duplex )
    tuck re-encode >r re-decode r> <duplex-stream> ;

: with-stream* ( stream quot -- )
    >r [ in>> ] [ out>> ] bi r> with-streams* ; inline

: with-stream ( stream quot -- )
    >r [ in>> ] [ out>> ] bi r> with-streams ; inline
