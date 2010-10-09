! Copyright (C) 2008, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays byte-vectors destructors io
io.encodings io.private io.streams.sequence kernel namespaces
sequences sequences.private ;
IN: io.streams.byte-array

M: byte-vector stream-element-type drop +byte+ ;

: <byte-writer> ( encoding -- stream )
    512 <byte-vector> swap <encoder> ;

: with-byte-writer ( encoding quot -- byte-array )
    [ <byte-writer> ] dip [ output-stream get ] compose with-output-stream*
    dup encoder? [ stream>> ] when >byte-array ; inline

TUPLE: byte-reader { underlying byte-array read-only } { i array-capacity } ;

M: byte-reader stream-element-type drop +byte+ ;

M: byte-reader stream-read-partial stream-read ;
M: byte-reader stream-read sequence-read ;
M: byte-reader stream-read1 sequence-read1 ;
M: byte-reader stream-read-until sequence-read-until ;
M: byte-reader dispose drop ;

M: byte-reader stream-tell i>> ;
M: byte-reader stream-seek (stream-seek) ;

: <byte-reader> ( byte-array encoding -- stream )
    [ B{ } like 0 byte-reader boa ] dip <decoder> ;

: with-byte-reader ( byte-array encoding quot -- )
    [ <byte-reader> ] dip with-input-stream* ; inline
