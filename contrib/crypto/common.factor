IN: crypto-internals
USING: kernel io strings sequences namespaces math parser lists ;

: w+ ( int -- int ) + HEX: ffffffff bitand ; inline
: nth-int ( string n -- int ) 2 shift dup 4 + rot <slice> le> ; inline
: nth-int-be ( string n -- int ) 2 shift dup 4 + rot <slice> be> ; inline
: float-sin ( int -- int ) sin abs 4294967296 * >bignum ; inline
: update ( num var -- ) [ w+ ] change ; inline

: update-old-new ( old new -- )
    [ get >r get r> ] 2keep >r >r w+ dup r> set r> set ; inline
    
! calculate pad length.  leave 8 bytes for length after padding
: zero-pad-length ( length -- pad-length )
    dup 56 < 55 119 ? swap - ; ! one less for first byte of padding 0x80

! pad 0x80 then 00 til 8 bytes left, then 64bit length in bits
: pad-string-md5 ( string  -- padded-string )
    [
        dup % HEX: 80 ,
        dup length HEX: 3f bitand zero-pad-length 0 <string> %
        dup length 3 shift 8 >le %
    ] "" make nip ;

: pad-string-sha1 ( string  -- padded-string )
    [
        dup % HEX: 80 ,
        dup length HEX: 3f bitand zero-pad-length 0 <string> %
        dup length 3 shift 8 >be %
    ] "" make nip ;

: num-blocks ( length -- num ) -6 shift ;
: get-block ( string num -- string ) 6 shift dup 64 + rot <slice> ;
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
