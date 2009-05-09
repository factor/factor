! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors alien alien.accessors math io ;
IN: io.streams.memory

TUPLE: memory-stream alien index ;

: <memory-stream> ( alien -- stream )
    0 memory-stream boa ;

M: memory-stream stream-element-type drop +byte+ ;

M: memory-stream stream-read1
    [ [ alien>> ] [ index>> ] bi alien-unsigned-1 ]
    [ [ 1+ ] change-index drop ] bi ;
