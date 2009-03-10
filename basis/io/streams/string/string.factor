! Copyright (C) 2003, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io kernel math namespaces sequences sbufs
strings generic splitting continuations destructors sequences.private
io.streams.plain io.encodings math.order growable io.streams.sequence ;
IN: io.streams.string

<PRIVATE

SINGLETON: null-encoding

M: null-encoding decode-char drop stream-read1 ;

PRIVATE>

M: growable dispose drop ;

M: growable stream-write1 push ;
M: growable stream-write push-all ;
M: growable stream-flush drop ;

: <string-writer> ( -- stream )
    512 <sbuf> ;

: with-string-writer ( quot -- str )
    <string-writer> swap [ output-stream get ] compose with-output-stream*
    >string ; inline

! New implementation

TUPLE: string-reader { underlying string read-only } { i array-capacity } ;

M: string-reader stream-read-partial stream-read ;
M: string-reader stream-read sequence-read ;
M: string-reader stream-read1 sequence-read1 ;
M: string-reader stream-read-until sequence-read-until ;
M: string-reader dispose drop ;

: <string-reader> ( str -- stream )
    0 string-reader boa null-encoding <decoder> ;

: with-string-reader ( str quot -- )
    [ <string-reader> ] dip with-input-stream ; inline

INSTANCE: growable plain-writer
