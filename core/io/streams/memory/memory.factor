! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors io kernel ;
IN: io.streams.memory

TUPLE: memory-stream alien ;

: <memory-stream> ( alien -- stream )
    memory-stream boa ;

INSTANCE: memory-stream input-stream

M: memory-stream stream-element-type drop +byte+ ;

M: memory-stream stream-read1
    [ 1 over <displaced-alien> ] change-alien drop
    0 alien-unsigned-1 ; inline

: with-memory-reader ( alien quot -- )
    [ <memory-stream> ] dip with-input-stream* ; inline
