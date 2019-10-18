IN: crypto-internals
USING: kernel io strings sequences namespaces math parser ;

IN: crypto
: >32-bit ( n -- n ) HEX: ffffffff bitand ; inline
: >64-bit ( n -- n ) HEX: ffffffffffffffff bitand ; inline

IN: crypto-internals
: w+ ( int int -- int ) + >32-bit ; inline
: nth-int ( string n -- int ) 2 shift dup 4 + rot <slice> le> ; inline
: nth-int-be ( string n -- int ) 2 shift dup 4 + rot <slice> be> ; inline
: update ( num var -- ) [ w+ ] change ; inline

: update-old-new ( old new -- )
    [ get >r get r> ] 2keep >r >r w+ dup r> set r> set ; inline
    
: calculate-pad-length ( length -- pad-length )
    dup 56 < 55 119 ? swap - ;

: preprocess-plaintext ( string big-endian? -- padded-string )
    #! pad 0x80 then 00 til 8 bytes left, then 64bit length in bits
    >r >sbuf r> over [
        HEX: 80 ,
        dup length HEX: 3f bitand calculate-pad-length 0 <string> %
        length 3 shift 8 rot [ >be ] [ >le ] if %
    ] "" make dupd nappend ;

SYMBOL: bytes-read
SYMBOL: big-endian?

: pad-last-block ( str big-endian? length -- str )
    [
        rot %
        HEX: 80 ,
        dup HEX: 3f bitand calculate-pad-length 0 <string> %
        3 shift 8 rot [ >be ] [ >le ] if %
    ] "" make 64 group ;

: shift-mod ( n s w -- n ) >r shift r> 1 swap shift 1 - bitand ; inline


IN: crypto

: bitroll ( n s w -- n' )
     #! Roll n by s bits to the left, wrapping around after
     #! w bits.
     [ 1 - bitand ] keep
     over 0 < [ [ + ] keep ] when
     [ shift-mod ] 3keep
     [ - ] keep shift-mod bitor ; inline

: bitroll-32 ( n s -- n' ) 32 bitroll ;
: bitroll-64 ( n s -- n' ) 64 bitroll ;
: hex-string ( str -- str ) [ [ >hex 2 48 pad-left % ] each ] "" make ;
: slice3 ( n seq -- a b c ) >r dup 3 + r> <slice> first3 ;

: 4dup ( a b c d -- a b c d a b c d )
    >r >r 2dup r> r> 2swap >r >r 2dup r> r> 2swap ;

: 4keep ( w x y z quot -- w x y z )
    >r 4dup r> swap >r swap >r swap >r swap >r call r> r> r> r> ; inline
