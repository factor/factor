! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.streams.null
USING: kernel io io.timeouts io.streams.duplex continuations ;

TUPLE: null-stream ;

M: null-stream dispose drop ;
M: null-stream set-timeout 2drop ;

TUPLE: null-reader < null-stream ;

M: null-reader stream-readln drop f ;
M: null-reader stream-read1 drop f ;
M: null-reader stream-read-until 2drop f f ;
M: null-reader stream-read 2drop f ;

TUPLE: null-writer < null-stream ;

M: null-writer stream-write1 2drop ;
M: null-writer stream-write 2drop ;
M: null-writer stream-nl drop ;
M: null-writer stream-flush drop ;
M: null-writer stream-format 3drop ;
M: null-writer make-span-stream nip ;
M: null-writer make-block-stream nip ;
M: null-writer make-cell-stream nip ;
M: null-writer stream-write-table 3drop ;

: with-null-reader ( quot -- )
    T{ null-reader } swap with-input-stream* ; inline

: with-null-writer ( quot -- )
    T{ null-writer } swap with-output-stream* ; inline

: with-null-stream ( quot -- )
    T{ duplex-stream f T{ null-reader } T{ null-writer } }
    swap with-stream* ; inline
