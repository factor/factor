! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: destructors io io.encodings.binary io.files
io.streams.limited kernel random random.private
sequences.private ;
IN: io.streams.random

TUPLE: random-stream ;

C: <random-stream> random-stream

M: random-stream stream-element-type drop +byte+ ;

M: random-stream stream-read-unsafe
    drop [ dup random-bytes ] [ 0 swap copy-unsafe ] bi* ;

M: random-stream stream-read1 drop 256 random ;

M: random-stream stream-read-partial-unsafe stream-read-unsafe ;

M: random-stream dispose drop ;

INSTANCE: random-stream input-stream

: random-file ( n path -- )
    [ <random-stream> swap limit-stream ]
    [ binary <file-writer> ] bi* stream-copy ;
