! Copyright (C) 2007, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel io destructors io.streams.plain ;
IN: io.streams.null

SINGLETONS: null-reader null-writer ;
UNION: null-stream null-reader null-writer ;
INSTANCE: null-reader input-stream
INSTANCE: null-writer output-stream
INSTANCE: null-writer plain-writer

M: null-stream dispose drop ;

M: null-reader stream-element-type drop +byte+ ;
M: null-reader stream-readln drop f ;
M: null-reader stream-read1 drop f ;
M: null-reader stream-read-until 2drop f f ;
M: null-reader stream-read-unsafe 3drop 0 ;
M: null-reader stream-read-partial-unsafe 3drop 0 ;

M: null-writer stream-element-type drop +byte+ ;
M: null-writer stream-write1 2drop ;
M: null-writer stream-write 2drop ;
M: null-writer stream-flush drop ;

: with-null-reader ( quot -- )
    null-reader swap with-input-stream* ; inline

: with-null-writer ( quot -- )
    null-writer swap with-output-stream* ; inline
