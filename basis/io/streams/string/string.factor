! Copyright (C) 2003, 2009 Slava Pestov, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors destructors io io.encodings io.streams.sequence
kernel math sbufs sequences sequences.private strings ;
IN: io.streams.string

! Readers
TUPLE: string-reader { underlying string read-only } { i array-capacity } ;
INSTANCE: string-reader input-stream

M: string-reader stream-element-type drop +character+ ; inline

M: string-reader stream-read-unsafe sequence-read-unsafe ;
M: string-reader stream-read1 sequence-read1 ;
M: string-reader stream-read-until sequence-read-until ;
M: string-reader stream-readln
    dup >sequence-stream< bounds-check? [
        "\r\n" over sequence-read-until CHAR: \r eq? [
            over >sequence-stream< dupd ?nth CHAR: \n eq?
            [ 1 + pick i<< ] [ drop ] if
        ] when nip "" or
    ] [ drop f ] if ;

M: string-reader stream-tell i>> ;
M: string-reader stream-seek sequence-seek ;
M: string-reader stream-seekable? drop t ; inline
M: string-reader stream-length underlying>> length ;
M: string-reader dispose drop ;

: <string-reader> ( str -- stream )
    0 string-reader boa ;

: with-string-reader ( str quot -- )
    [ <string-reader> ] dip with-input-stream ; inline

! Writers
M: sbuf stream-element-type drop +character+ ; inline
M: sbuf stream-tell length ; inline

: <string-writer> ( -- stream )
    512 <sbuf> ; inline

: with-string-writer ( quot -- str )
    <string-writer> [
        swap with-output-stream*
    ] keep >string ; inline
