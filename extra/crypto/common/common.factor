USING: arrays kernel io io.binary sbufs splitting strings sequences
namespaces math math.parser parser hints ;
IN: crypto.common

: >32-bit ( x -- y ) HEX: ffffffff bitand ; inline
: >64-bit ( x -- y ) HEX: ffffffffffffffff bitand ; inline

: w+ ( int int -- int ) + >32-bit ; inline

: (nth-int) ( string n -- int )
    2 shift dup 4 + rot <slice> ; inline
    
: nth-int ( string n -- int ) (nth-int) le> ; inline
    
: nth-int-be ( string n -- int ) (nth-int) be> ; inline

: update ( num var -- ) [ w+ ] change ; inline
    
: calculate-pad-length ( length -- pad-length )
    dup 56 < 55 119 ? swap - ;

: preprocess-plaintext ( string big-endian? -- padded-string )
    #! pad 0x80 then 00 til 8 bytes left, then 64bit length in bits
    >r >sbuf r> over [
        HEX: 80 ,
        dup length HEX: 3f bitand
        calculate-pad-length 0 <string> %
        length 3 shift 8 rot [ >be ] [ >le ] if %
    ] "" make over push-all ;

SYMBOL: bytes-read
SYMBOL: big-endian?

: pad-last-block ( str big-endian? length -- str )
    [
        rot %
        HEX: 80 ,
        dup HEX: 3f bitand calculate-pad-length 0 <string> %
        3 shift 8 rot [ >be ] [ >le ] if %
    ] "" make 64 group ;

: shift-mod ( n s w -- n )
    >r shift r> 1 swap shift 1 - bitand ; inline

: update-old-new ( old new -- )
    [ get >r get r> ] 2keep >r >r w+ dup r> set r> set ; inline

: bitroll ( x s w -- y )
     [ 1 - bitand ] keep
     over 0 < [ [ + ] keep ] when
     [ shift-mod ] 3keep
     [ - ] keep shift-mod bitor ; inline

: bitroll-32 ( n s -- n' ) 32 bitroll ;

HINTS: bitroll-32 bignum fixnum ;

: bitroll-64 ( n s -- n' ) 64 bitroll ;

HINTS: bitroll-64 bignum fixnum ;

: hex-string ( seq -- str )
    [ [ >hex 2 48 pad-left % ] each ] "" make ;

: slice3 ( n seq -- a b c ) >r dup 3 + r> <slice> first3 ;

: seq>2seq ( seq -- seq1 seq2 )
    #! { abcdefgh } -> { aceg } { bdfh }
    2 group flip dup empty? [ drop { } { } ] [ first2 ] if ;

: 2seq>seq ( seq1 seq2 -- seq )
    #! { aceg } { bdfh } -> { abcdefgh }
    swap ! error?
    [ 2array flip concat ] keep like ;

: mod-nth ( n seq -- elt )
    #! 5 "abcd" -> b
    [ length mod ] keep nth ;
