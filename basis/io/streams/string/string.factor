! Copyright (C) 2003, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io kernel math namespaces sequences sbufs
strings generic splitting continuations destructors sequences.private
io.streams.plain io.encodings math.order growable io.streams.sequence ;
IN: io.streams.string

! Readers
TUPLE: string-reader { underlying string read-only } { i array-capacity } ;

M: string-reader stream-element-type drop +character+ ;
M: string-reader stream-read-partial stream-read ;
M: string-reader stream-read sequence-read ;
M: string-reader stream-read1 sequence-read1 ;
M: string-reader stream-read-until sequence-read-until ;
M: string-reader dispose drop ;

<PRIVATE
SINGLETON: null-encoding
M: null-encoding decode-char drop stream-read1 ;
PRIVATE>

: <string-reader> ( str -- stream )
    0 string-reader boa null-encoding <decoder> ;

: with-string-reader ( str quot -- )
    [ <string-reader> ] dip with-input-stream ; inline

! Writers
M: sbuf stream-element-type drop +character+ ;

: <string-writer> ( -- stream )
    512 <sbuf> ;

: with-string-writer ( quot -- str )
    <string-writer> [
        swap with-output-stream*
    ] keep >string ; inline