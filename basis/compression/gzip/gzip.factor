! Copyright (C) 2020 Jacob Fischer and Abtin Molavi.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs bit-arrays byte-arrays
combinators compression.huffman fry kernel literals locals make
math math.bits math.ranges namespaces sequences splitting
vectors ;
IN: compression.gzip

SYMBOL: lit-dict
SYMBOL: dist-dict 
SYMBOL: lit-vec

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
{ [ dup 19 < ]  [ [ 11 - 2 /i 265 + ] [ 11 - 2 mod 1 <bits> >bit-array  ] bi 2array ] }
{ [ dup 35 < ]  [ [ 19 - 4 /i 269 + ] [ 19 - 4 mod 2 <bits> >bit-array  ] bi 2array ] }
{ [ dup 67 < ]  [ [ 35 - 8 /i 273 + ] [ 35 - 8 mod 3 <bits> >bit-array  ] bi 2array ] }
{ [ dup 131 < ] [ [ 67 - 16 /i 277 + ] [ 67 - 16 mod 4 <bits> >bit-array  ] bi 2array ] }
{ [ dup 258 < ] [ [ 131 - 32 /i 281 + ] [ 131 - 32 mod 5 <bits> >bit-array  ] bi 2array ] }
[ drop 285 ]
}
cond ;

: dist-to-code ( dist -- code )
{
{ [ dup 5 <  ] [ -1 + ] }
{ [ dup 9 < ]  [ [ 5 - 2 /i 4 + ] [ 5 - 2 mod 1 <bits> >bit-array  ] bi 2array ] }
{ [ dup 17 < ]  [ [ 9 - 4 /i 6 + ] [ 9 - 4 mod 2 <bits> >bit-array  ] bi 2array ] }
{ [ dup 33 < ]  [ [ 17 - 8 /i 8 + ] [ 17 - 8 mod 3 <bits> >bit-array  ] bi 2array ] }
{ [ dup 65 < ] [ [ 33 - 16 /i 10 + ] [ 33 - 16 mod 4 <bits> >bit-array  ] bi 2array ] }
{ [ dup 129 < ] [ [ 65 - 32 /i 12 + ] [ 65 - 32 mod 5 <bits> >bit-array  ] bi 2array ] }
{ [ dup 257 < ] [ [ 129 - 64 /i 14 + ] [ 129 - 64 mod 6 <bits> >bit-array  ] bi 2array ] }
{ [ dup 513 < ] [ [ 257 - 128 /i 16 + ] [ 257 - 128 mod 7 <bits> >bit-array  ] bi 2array ] }
{ [ dup 1025 < ] [ [ 513 - 256 /i 18 + ] [ 513 - 256 mod 8 <bits> >bit-array  ] bi 2array ] }
{ [ dup 2049 < ] [ [ 1025 - 512 /i 20 + ] [ 1025 - 512 mod 9 <bits> >bit-array  ] bi 2array ] }
{ [ dup 4097 < ] [ [ 2049 - 1024 /i 22 + ] [ 2049 - 1024 mod  10 <bits> >bit-array  ] bi 2array ] }
{ [ dup 8193 < ] [ [ 4097 - 2048 /i 24 + ] [ 4097 - 2048 mod 11 <bits> >bit-array  ] bi 2array ] }
{ [ dup 16385 < ] [ [ 8193 - 4096 /i 26 + ] [ 8193 - 4096 mod 12 <bits> >bit-array  ] bi 2array ] }
[ [ 8193 - 4096 /i 28 + ] [ 8193 - 4096 mod  13 <bits> >bit-array  ] bi 2array ] 
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
    dup array? [ [ first 5 <bits> >bit-array reverse ] [ second ] bi 2array ] [ 5 <bits> >bit-array reverse ] if  ;

: lit-to-bits ( lit -- bits )
     dup array? [ [ first (lit-to-bits) ] [ second ] bi 2array ] [ (lit-to-bits) ] if  ;
 
: pair-to-bits ( l,d -- bits )
    [ first lit-to-bits ] [ second dist-to-bits ] bi 2array ;

: vec-to-bits ( vec -- bitarr )
    [ dup array? [ pair-to-bits ] [ (lit-to-bits) ] if ] map ;


! fixed huffman compression function 
: (compress-fixed) ( bytes -- bits )
    compress-lz77 vec-to-lits vec-to-bits ;

<<
:: R2, ( n -- ) n ,     n 2 64 * + ,     n 1 64 * + ,     n 3 64 * + , ;
:: R4, ( n -- ) n R2,   n 2 16 * + R2,   n 1 16 * + R2,   n 3 16 * + R2, ;
:: R6, ( n -- ) n R4,   n 2 4 * + R4,    n 1 4 * + R4,    n 3 4 * + R4, ;
>>
CONSTANT: bit-reverse-table $[
    [ 0 R6, 2 R6, 1 R6, 3 R6, ] B{ } make
]
: reverse-bits ( byte-array -- byte-array' )
    [ bit-reverse-table nth ] B{ } map-as ;

: byte-array>bit-array ( byte-array -- bit-array )
    [ length 8 * ] [ bit-array boa ] bi ;

: bytes-to-bits ( bytes -- bits )
    reverse-bits byte-array>bit-array ;

: bits-to-bytes ( bits -- bytes )
    underlying>> reverse-bits ;

: seq-of-bits-to-byte-arr ( seq -- byte-array )
    concat bits-to-bytes ;

! Dynamic Huffman

! Given an lz77 compressed block, constructs the huffman code tables
: build-dicts ( vec -- lit-dict dist-dict )
    [ [ dup array? [ first ] when dup array? [ first ] when ] map generate-canonical-codes ]
    [ [ dup array? [ second ] when dup array? [ first ] when ] map generate-canonical-codes ] bi ;


! Use the given dictionary to replace the element with its code
:: replace-one ( ele code-dict  --  new-ele )
   ele array? [ ele first code-dict at ele second 2array ] [ ele code-dict at ] if ;

! replace both elements of a length distance pair with their codes
: replace-pair (  pair  -- new-pair  )
    [ first lit-dict get replace-one ]  [ second dist-dict get replace-one ] bi 2array ;
  
! Replace all vector elements with their codes
: vec-to-codes ( vec -- new-vec )
    [ dup array? [ replace-pair ] [ lit-dict get replace-one ] if ]  map ;

! Dictionary encoding
: lit-code-lens ( -- len-seq )
     285 [0..b] [ lit-dict get at* [ length ] [ drop 0 ] if ] map [ zero? ] trim-tail ;

: dist-code-lens ( -- len-seq )
     31 [0..b] [ lit-dict get at* [ length ] [ drop 0 ] if ] map [ zero? ] trim-tail ;

:: replace-0-single ( m len-seq  -- new-len-seq )
    m 11 < [ len-seq m 0 <array> 17 m 3 - 3 <bits> >bit-array 2array 1array replace ]
           [ len-seq m 0 <array> 18 m 11 - 7 <bits> >bit-array 2array 1array replace ]    
    if ;

:: replace-0-range ( range len-seq -- new-len-seq )
    range empty? [ len-seq ] [ range first range 1 tail len-seq replace-0-range replace-0-single ] if ;

: replace-0 ( len-seq -- new-len-seq )
    2 139 (a..b) swap replace-0-range ;

:: replace-runs ( n len-seq  -- new-len-seq )
    len-seq 7 n <array> { n { 16 ?{ t t } } } replace  
    6 n <array> { n { 16 ?{ f t } } } replace 
    5 n <array> { n { 16 ?{ t f } } } replace 
    4 n <array>  { n { 16 ?{ f f } } }  replace  ;

:: replace-all-runs ( range len-seq  -- new-len-seq )
   range empty? [ len-seq ] [ range first range 1 tail len-seq replace-all-runs replace-runs ] if ;

: run-free-lit ( -- len-seq )
    0 285 [a..b] lit-code-lens replace-0 replace-all-runs ;

: run-free-dist ( -- len-seq )
   0 31 [a..b] dist-code-lens replace-0 replace-all-runs ;
        
: run-free-codes ( -- len-seq )
    run-free-lit run-free-dist append ;

: code-len-dict ( -- code-dict )
    run-free-codes [ dup array? [ first ] when ] map generate-canonical-codes ;

: compressed-lens ( -- len-seq )
   run-free-codes  [ dup array? [ [ first code-len-dict at ] [ second ] bi 2array ] [ code-len-dict at ] if ] map ;

CONSTANT: clen-shuffle { 16 17 18 0 8 7 9 6 10 5 11 4 12 3 13 2 14 1 15 }

! Data that precedes dictionary embedding to allow for decoding 
: clen-seq ( -- len-seq )
    clen-shuffle [ code-len-dict at* [ length ] [ drop 0 ] if ] map [ zero? ] trim-tail ;

: clen-bits ( -- bit-arr )
    clen-seq [ 3 <bits> >bit-array  ] map  ;
 
: h-lit ( -- bit-arr )
    lit-code-lens length 257 - 5 <bits> >bit-array ;

: h-dist ( -- bit-arr )
    dist-code-lens length 1 - 5 <bits> >bit-array  ;

: h-clen ( -- bit-arr )
    clen-seq length 4 - 4 <bits> >bit-array  ;

: dynamic-headers ( -- bit-arr-seq )
    ?{ t t f } h-lit h-dist h-clen 4array concat ;

! Compresses a block with dynamic huffman compression.
: (compress-dynamic) ( lit-seq -- bit-arr-seq  )
   [ compress-lz77 vec-to-lits lit-vec set 
    lit-vec get build-dicts  
    dist-dict set 
    lit-dict set
    dynamic-headers clen-bits compressed-lens 
    lit-vec get vec-to-codes 4array ] with-scope ;

: flatten-single ( ele -- bits )
    dup array? [ concat ] when ;

: flatten-lens ( compressed-lens -- bits )
    [ flatten-single ] map concat ; 

: flatten-pair ( pair  -- bits )
  dup array? [ [ first flatten-single ] [ second flatten-single ] bi append ] when ; 

: compressed>byte-array ( bit-arr-seq  -- byte-array )
    { [ first ] [ second concat ] [ third flatten-lens ] [ fourth [ flatten-pair ] map concat ] } cleave 4array concat underlying>> ;

! : write-dynamic-compressed  
: compress-dynamic ( byte-array -- byte-array )
    (compress-dynamic) compressed>byte-array ;

: compress-fixed ( byte-array -- byte-array )
    (compress-fixed) [ flatten-pair ] map concat ?{ t f t } swap append ;

