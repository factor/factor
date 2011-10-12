! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors alien alien.accessors math io ;
IN: io.streams.memory

TUPLE: memory-stream alien ;

: <memory-stream> ( alien -- stream )
    memory-stream boa ;

M: memory-stream stream-element-type drop +byte+ ;

M: memory-stream stream-read1
    [ 1 over <displaced-alien> ] change-alien drop
    0 alien-unsigned-1 ; inline
