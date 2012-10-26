! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: destructors io kernel sequences ;
IN: io.streams.zeros

TUPLE: zero-stream ;

C: <zero-stream> zero-stream

M: zero-stream stream-element-type drop +byte+ ;

M: zero-stream stream-read-unsafe drop [ drop 0 ] map! drop ;

M: zero-stream stream-read1 drop 0 ;

M: zero-stream stream-read-partial-unsafe stream-read-unsafe ;

M: zero-stream dispose drop ;

INSTANCE: zero-stream input-stream
