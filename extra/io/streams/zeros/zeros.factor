! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators destructors io io.directories
io.encodings.binary io.files kernel math sequences ;
IN: io.streams.zeros

TUPLE: zero-stream ;

C: <zero-stream> zero-stream

M: zero-stream stream-element-type drop +byte+ ;

M: zero-stream stream-read-unsafe
    drop over head-slice [ drop 0 ] map! drop ;

M: zero-stream stream-read1 drop 0 ;

M: zero-stream stream-read-partial-unsafe stream-read-unsafe ;

M: zero-stream dispose drop ;

INSTANCE: zero-stream input-stream

<PRIVATE

: (zero-file) ( n path -- )
    binary
    [ 1 - seek-absolute seek-output 0 write1 ] with-file-writer ;

PRIVATE>

ERROR: invalid-file-size n path ;

: zero-file ( n path -- )
    {
        { [ over 0 < ] [ invalid-file-size ] }
        { [ over 0 = ] [ nip touch-file ] }
        [ (zero-file) ]
    } cond ;
