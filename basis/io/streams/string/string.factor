! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io kernel math namespaces sequences sbufs
strings generic splitting continuations destructors
io.streams.plain io.encodings math.order growable ;
IN: io.streams.string

<PRIVATE

: harden-as ( seq growble-exemplar -- newseq )
    underlying>> like ;

: growable-read-until ( growable n -- str )
    >fixnum dupd tail-slice swap harden-as dup reverse-here ;

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

M: growable stream-read1 [ f ] [ pop ] if-empty ;

: find-last-sep ( seq seps -- n )
    swap [ memq? ] curry find-last drop ;

M: growable stream-read-until
    [ find-last-sep ] keep over [
        [ swap 1+ growable-read-until ] 2keep [ nth ] 2keep
        set-length
    ] [
        [ swap drop 0 growable-read-until f like f ] keep
        delete-all
    ] if ;

M: growable stream-read
    [
        drop f
    ] [
        [ length swap - 0 max ] keep
        [ swap growable-read-until ] 2keep
        set-length
    ] if-empty ;

M: growable stream-read-partial
    stream-read ;

: <string-reader> ( str -- stream )
    >sbuf dup reverse-here null-encoding <decoder> ;

: with-string-reader ( str quot -- )
    [ <string-reader> ] dip with-input-stream ; inline

INSTANCE: growable plain-writer
