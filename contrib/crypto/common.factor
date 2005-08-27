IN: crypto
USING: kernel io strings sequences namespaces math prettyprint
unparser test parser lists ;

: rot4 ( a b c d -- b c d a )
    >r rot r> swap ;

: (shift-mod) ( n s w -- n )
     >r shift r> 1 swap shift mod ;

: bitroll ( n s w -- n )
     #! Roll n by s bits to the left, wrapping around after
     #! w bits.
     [ mod ] keep
     over 0 < [ [ + ] keep ] when
     [
         (shift-mod)
     ] 3keep
     [ - ] keep (shift-mod) bitor ;


: w+ ( int -- int )
    + HEX: ffffffff bitand ;

: nth-int ( string n -- int )
    4 * dup 4 + rot subseq le> ;

: nth-int-be ( string n -- int )
    4 * dup 4 + rot subseq be> ;

: float-sin ( int -- int )
    sin abs 4294967296 * >bignum ;

: update ( num var -- )
    [ w+ ] change ;

: update-old-new ( old new -- )
    [ get >r get r> ] 2keep >r >r w+ dup r> set r> set ;
    
! calculate pad length.  leave 8 bytes for length after padding
: zero-pad-length ( length -- pad-length )
    dup 64 mod 56 < 55 119 ? swap - ; ! one less for first byte of padding 0x80

! pad 0x80 then 00 til 8 bytes left, then 64bit length in bits
: pad-string-md5 ( string  -- padded-string )
    [
        dup % "\u0080" %
        dup length 64 mod zero-pad-length 0 fill %
        dup length 8 * 8 >le %
    ] make-string nip ;

: pad-string-sha1 ( string  -- padded-string )
    [
        dup % "\u0080" %
        dup length 64 mod zero-pad-length 0 fill %
        dup length 8 * 8 >be %
    ] make-string nip ;

: num-blocks ( length -- num )
    64 /i ;

: get-block ( string num -- string )
    64 * dup 64 + rot subseq ;

: hex-string ( str -- str )
    [
        [
            >hex 2 48 pad-left %
        ] each
    ] make-string ;

