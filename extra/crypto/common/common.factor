USING: arrays kernel io io.binary sbufs splitting strings sequences
namespaces math math.parser parser hints math.bitfields.lib ;
IN: crypto.common

: w+ ( int int -- int ) + 32 bits ; inline

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

: update-old-new ( old new -- )
    [ get >r get r> ] 2keep >r >r w+ dup r> set r> set ; inline

: hex-string ( seq -- str )
    [ [ >hex 2 48 pad-left % ] each ] "" make ;

: slice3 ( n seq -- a b c ) >r dup 3 + r> <slice> first3 ;

: seq>2seq ( seq -- seq1 seq2 )
    #! { abcdefgh } -> { aceg } { bdfh }
    2 group flip dup empty? [ drop { } { } ] [ first2 ] if ;

: 2seq>seq ( seq1 seq2 -- seq )
    #! { aceg } { bdfh } -> { abcdefgh }
    [ 2array flip concat ] keep like ;

: mod-nth ( n seq -- elt )
    #! 5 "abcd" -> b
    [ length mod ] [ nth ] bi ;
