! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations io io.encodings io.encodings.private
io.timeouts debugger inspector listener accessors ;
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

M: duplex-stream stream-flush
    out stream-flush ;

M: duplex-stream stream-readln
    in stream-readln ;

M: duplex-stream stream-read1
    in stream-read1 ;

M: duplex-stream stream-read-until
    in stream-read-until ;

M: duplex-stream stream-read-partial
    in stream-read-partial ;

M: duplex-stream stream-read
    in stream-read ;

M: duplex-stream stream-write1
    out stream-write1 ;

M: duplex-stream stream-write
    out stream-write ;

M: duplex-stream stream-nl
    out stream-nl ;

M: duplex-stream stream-format
    out stream-format ;

M: duplex-stream make-span-stream
    out make-span-stream ;

M: duplex-stream make-block-stream
    out make-block-stream ;

M: duplex-stream make-cell-stream
    out make-cell-stream ;

M: duplex-stream stream-write-table
    out stream-write-table ;

M: duplex-stream stream-read-quot
    in stream-read-quot ;

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
    tuck reencode >r redecode r> <duplex-stream> ;

: with-stream* ( stream quot -- )
    >r [ in>> ] [ out>> ] bi r> with-streams* ; inline

: with-stream ( stream quot -- )
    >r [ in>> ] [ out>> ] bi r> with-streams ; inline
