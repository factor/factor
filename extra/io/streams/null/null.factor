! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.streams.null
USING: kernel io ;

TUPLE: null-stream ;

M: null-stream stream-close drop ;
M: null-stream set-timeout 2drop ;
M: null-stream stream-readln drop f ;
M: null-stream stream-read1 drop f ;
M: null-stream stream-read-until 2drop f f ;
M: null-stream stream-read 2drop f ;
M: null-stream stream-write1 2drop ;
M: null-stream stream-write 2drop ;
M: null-stream stream-nl drop ;
M: null-stream stream-flush drop ;
M: null-stream stream-format 3drop ;
M: null-stream make-span-stream nip ;
M: null-stream make-block-stream nip ;
M: null-stream make-cell-stream nip ;
M: null-stream stream-write-table 3drop ;

: with-null-stream ( quot -- )
    T{ null-stream } swap with-stream* ; inline
