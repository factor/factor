! Copyright (C) 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.streams.duplex
USING: kernel continuations io ;

! We ensure that the stream can only be closed once, to preserve
! integrity of duplex I/O ports.

TUPLE: duplex-stream in out closed? ;

: <duplex-stream> ( in out -- stream )
    f duplex-stream construct-boa ;

TUPLE: check-closed ;

: check-closed ( stream -- )
    duplex-stream-closed?
    [ \ check-closed construct-boa throw ] when ;

: duplex-stream-in+ ( duplex -- stream )
    dup check-closed duplex-stream-in ;

: duplex-stream-out+ ( duplex -- stream )
    dup check-closed duplex-stream-out ;

M: duplex-stream stream-flush
    duplex-stream-out+ stream-flush ;

M: duplex-stream stream-readln
    duplex-stream-in+ stream-readln ;

M: duplex-stream stream-read1
    duplex-stream-in+ stream-read1 ;

M: duplex-stream stream-read-until
    duplex-stream-in+ stream-read-until ;

M: duplex-stream stream-read-partial
    duplex-stream-in+ stream-read-partial ;

M: duplex-stream stream-read
    duplex-stream-in+ stream-read ;

M: duplex-stream stream-write1
    duplex-stream-out+ stream-write1 ;

M: duplex-stream stream-write
    duplex-stream-out+ stream-write ;

M: duplex-stream stream-nl
    duplex-stream-out+ stream-nl ;

M: duplex-stream stream-format
    duplex-stream-out+ stream-format ;

M: duplex-stream make-span-stream
    duplex-stream-out+ make-span-stream ;

M: duplex-stream make-block-stream
    duplex-stream-out+ make-block-stream ;

M: duplex-stream make-cell-stream
    duplex-stream-out+ make-cell-stream ;

M: duplex-stream stream-write-table
    duplex-stream-out+ stream-write-table ;

M: duplex-stream stream-close
    #! The output stream is closed first, in case both streams
    #! are attached to the same file descriptor, the output
    #! buffer needs to be flushed before we close the fd.
    dup duplex-stream-closed? [
        t over set-duplex-stream-closed?
        [ dup duplex-stream-out stream-close ]
        [ dup duplex-stream-in stream-close ] [ ] cleanup
    ] unless drop ;

M: duplex-stream set-timeout
    2dup
    duplex-stream-in set-timeout
    duplex-stream-out set-timeout ;
