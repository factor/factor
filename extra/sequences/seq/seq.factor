! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math sequences sequences.extras sequences.private ;
IN: sequences.seq

! Experimental: possibly more natural implementation of some sequence words.

GENERIC#: seq-lengthen 1 ( seq n -- seq )
GENERIC#: seq-shorten 1 ( seq n -- seq )

: seq-set-length ( seq n -- seq ) [ swap set-length ] keepd ; inline

M: sequence seq-lengthen 2dup lengthd < [ seq-set-length ] [ drop ] if ; inline
M: sequence seq-shorten 2dup lengthd > [ seq-set-length ] [ drop ] if ; inline

: seq-push ( seq elt -- seq ) [ dup length ] dip set-nth-of ;

: seq-grow-copy ( dst n -- dst dst-n )
    [ over length + seq-lengthen ] keep 1 - ; inline

: seq-copy-unsafe ( dst dst-i src -- dst )
    0 over length check-length copy-loop ; inline

: seq-push-all ( dst src -- dst ) [ length seq-grow-copy ] keep seq-copy-unsafe ; inline

: check-grow-copy ( dst n src -- dst src n )
    over [ lengthd + lengthen ] 2keep ; inline

: seq-copy ( dst dst-n src -- dst ) check-grow-copy seq-copy-unsafe ; inline

<PRIVATE

: (seq-append) ( accum seq1 seq2 -- accum )
    [
        [ 0 ] dip [ seq-copy-unsafe ] [ length ] bi
    ] dip seq-copy-unsafe ; inline

PRIVATE>

: seq-append-as ( seq1 seq2 exemplar -- newseq )
    [ 2dup 2length + ] dip
    [ -rot (seq-append) ] new-like ; inline

GENERIC: seq-bounds-check? ( seq n -- ? )

M: integer seq-bounds-check?
    tuck lengthd > [ 0 >= ] [ drop f ] if ; inline

: seq-bounds-check ( seq n -- seq n )
    2dup seq-bounds-check? [ swap bounds-error ] unless ; inline

