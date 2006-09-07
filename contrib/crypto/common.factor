IN: crypto-internals
USING: kernel io strings sequences namespaces math parser ;

: w+ ( int -- int ) + HEX: ffffffff bitand ; inline
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

: shift-mod ( n s w -- n ) >r shift r> 1 swap shift 1 - bitand ; inline

IN: crypto
: bitroll ( n s w -- n )
     #! Roll n by s bits to the left, wrapping around after
     #! w bits.
     [ 1 - bitand ] keep
     over 0 < [ [ + ] keep ] when
     [ shift-mod ] 3keep
     [ - ] keep shift-mod bitor ; inline

: hex-string ( str -- str ) [ [ >hex 2 48 pad-left % ] each ] "" make ;
