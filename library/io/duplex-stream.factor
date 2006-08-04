! Copyright (C) 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: errors kernel ;

! We ensure that the stream can only be closed once, to preserve
! integrity of duplex I/O ports.

TUPLE: duplex-stream in out closed? ;

C: duplex-stream ( in out -- stream )
    [ set-duplex-stream-out ] keep
    [ set-duplex-stream-in ] keep ;

TUPLE: check-closed ;
: check-closed ( duplex -- )
    duplex-stream-closed? [ <check-closed> throw ] when ;

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

M: duplex-stream stream-read
    duplex-stream-in+ stream-read ;

M: duplex-stream stream-write1
    duplex-stream-out+ stream-write1 ;

M: duplex-stream stream-write
    duplex-stream-out+ stream-write ;

M: duplex-stream stream-terpri
    duplex-stream-out+ stream-terpri ;

M: duplex-stream stream-format
    duplex-stream-out+ stream-format ;

M: duplex-stream with-stream-style
    duplex-stream-out+ with-stream-style ;

M: duplex-stream with-nested-stream
    duplex-stream-out+ with-nested-stream ;

M: duplex-stream with-stream-table
    duplex-stream-out+ with-stream-table ;

M: duplex-stream stream-close
    #! The output stream is closed first, in case both streams
    #! are attached to the same file descriptor, the output
    #! buffer needs to be flushed before we close the fd.
    dup duplex-stream-closed? [
        t over set-duplex-stream-closed?
        dup duplex-stream-out stream-close
        dup duplex-stream-in stream-close
    ] unless drop ;

M: duplex-stream set-timeout
    2dup
    duplex-stream-in set-timeout
    duplex-stream-out set-timeout ;
