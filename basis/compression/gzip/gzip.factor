! Copyright (C) 2020 Jacob Fischer and Abtin Molavi.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs bit-arrays byte-arrays combinators fry
kernel locals math math.bits sequences vectors ;
IN: compression.gzip

! :: deflate-lz77 ( byte-array -- seq )

! LZ77 compression

:: longest-prefix-end ( ind seq -- i )
     seq length  [ ind swap seq subseq 0 ind seq subseq subseq? ] find-last-integer  ;

: subseq-length ( ind seq -- n )
    [ longest-prefix-end ] 2keep drop - ;

:: offset ( ind seq -- o )
    ind ind ind seq longest-prefix-end seq subseq seq subseq-start - ;

:: create-triple ( ind seq -- array )
    {
    ! no match
    { [ ind seq subseq-length 0 = ]  [ ind seq nth 0 0 3array ] } 
    ! end of sequence
    { [ ind seq longest-prefix-end seq length = ] [ ind seq offset ind seq subseq-length 1 -  seq last 3array ]  }
    ! general case
     [ ind seq offset ind seq subseq-length ind seq longest-prefix-end seq nth 3array ] 
    }
    cond ;

:: create-pair ( ind seq -- array )
    ! no match
     ind seq subseq-length 3 < 
    [ ind seq nth ] 
    ! match
    [ ind seq offset ind seq subseq-length  2array ] 
    if ;

: sum-vec ( vec -- n )
 [ dup array?  [ second  ] [ drop 1 ] if ] map-sum ;

:: compress-lz77 ( seq -- vec )
0 seq create-pair seq length <vector> ?push [ dup sum-vec seq length < ] [ dup sum-vec seq create-pair swap ?push ] while ;

: create-gzip-header ( -- header )
    { 31 139 8 0 0 0 255 0 } >byte-array ;

! Huffman Coding

! Fixed Huffman table encoding specified in section 3.2.5 of RFC 1951
: length-to-code ( length -- code )
{
{ [ dup 10 <  ] [ 254 + ] }
{ [ dup 19 < ]  [ [ 11 - 2 /i 265 + ] [ 11 - 2 mod 1 <bits> >bit-array reverse ] bi 2array ] }
{ [ dup 35 < ]  [ [ 19 - 4 /i 269 + ] [ 19 - 4 mod 2 <bits> >bit-array reverse ] bi 2array ] }
{ [ dup 67 < ]  [ [ 35 - 8 /i 273 + ] [ 35 - 8 mod 3 <bits> >bit-array reverse ] bi 2array ] }
{ [ dup 131 < ] [ [ 67 - 16 /i 277 + ] [ 67 - 16 mod 4 <bits> >bit-array reverse ] bi 2array ] }
{ [ dup 258 < ] [ [ 131 - 32 /i 281 + ] [ 131 - 32 mod 5 <bits> >bit-array reverse ] bi 2array ] }
[ drop 285 ]
}
cond ;

: dist-to-code ( dist -- code )
{
{ [ dup 5 <  ] [ -1 + ] }
{ [ dup 9 < ]  [ [ 5 - 2 /i 4 + ] [ 5 - 2 mod 1 <bits> >bit-array reverse ] bi 2array ] }
{ [ dup 17 < ]  [ [ 9 - 4 /i 6 + ] [ 9 - 4 mod 2 <bits> >bit-array reverse ] bi 2array ] }
{ [ dup 33 < ]  [ [ 17 - 8 /i 8 + ] [ 17 - 8 mod 3 <bits> >bit-array reverse ] bi 2array ] }
{ [ dup 65 < ] [ [ 33 - 16 /i 10 + ] [ 33 - 16 mod 4 <bits> >bit-array reverse ] bi 2array ] }
{ [ dup 129 < ] [ [ 65 - 32 /i 12 + ] [ 65 - 32 mod 5 <bits> >bit-array reverse ] bi 2array ] }
{ [ dup 257 < ] [ [ 129 - 64 /i 14 + ] [ 129 - 64 mod 6 <bits> >bit-array reverse ] bi 2array ] }
{ [ dup 513 < ] [ [ 257 - 128 /i 16 + ] [ 257 - 128 mod 7 <bits> >bit-array reverse ] bi 2array ] }
{ [ dup 1025 < ] [ [ 513 - 256 /i 18 + ] [ 513 - 256 mod 8 <bits> >bit-array reverse ] bi 2array ] }
{ [ dup 2049 < ] [ [ 1025 - 512 /i 20 + ] [ 1025 - 512 mod 9 <bits> >bit-array reverse ] bi 2array ] }
{ [ dup 4097 < ] [ [ 2049 - 1024 /i 22 + ] [ 2049 - 1024 mod  10 <bits> >bit-array reverse ] bi 2array ] }
{ [ dup 8193 < ] [ [ 4097 - 2048 /i 24 + ] [ 4097 - 2048 mod 11 <bits> >bit-array reverse ] bi 2array ] }
{ [ dup 16385 < ] [ [ 8193 - 4096 /i 26 + ] [ 8193 - 4096 mod 12 <bits> >bit-array reverse ] bi 2array ] }
[ [ 8193 - 4096 /i 12 + ] [ 8193 - 4096 mod  13 <bits> >bit-array reverse ] bi 2array ] 
}
cond ;
 
 ! Words for transforming our vector of (length, distance) pairs and bytes into literals using above table
: pair-to-code ( pr -- code )
 [ first length-to-code ]  [ second dist-to-code ] bi 2array ;

: vec-to-lits ( vec -- vec )
    [ dup array? [ pair-to-code ] [ ] if ] map ; 

! Words for using the fixed Huffman code to map literals to bit arrays
! This is the table in section 3.2.6
: (lit-to-bits) ( lit  -- bitarr  )
 {
    { [ dup 144 <  ] [ 48 + 8 <bits> >bit-array reverse ] }
    { [ dup 265 <  ] [ 144 - 400 + 9 <bits> >bit-array reverse ] }
    { [ dup 280 <  ] [ 265 - 7 <bits> >bit-array reverse ] }
    [ 280 - 192 + 8 <bits> >bit-array reverse ]
 }
 cond ;

! Gluing codes with their extra bits

: dist-to-bits ( dist -- bits )
    dup array? [ [ first 5 <bits> >bit-array  reverse ] [ second ] bi append ] [ 5 <bits> >bit-array reverse ] if  ;

: lit-to-bits ( lit -- bits )
     dup array? [ [ first (lit-to-bits) ] [ second ] bi append ] [ (lit-to-bits) ] if  ;
 
: pair-to-bits ( l,d -- bits )
    [ first lit-to-bits ] [ second dist-to-bits ] bi append ;

: vec-to-bits ( vec -- bitarr )
    [ dup array? [ pair-to-bits ] [ (lit-to-bits) ] if ] map ;

! fixed huffman compression function 
: compress-fixed ( bytes -- bits )
compress-lz77 vec-to-lits vec-to-bits ;

! Dynamic Huffman


! :: read-frequency-element ( element assoc -- dict )
!       element assoc at* [ 1 + element assoc set-at ] [  1 element assoc set-at ] if ;