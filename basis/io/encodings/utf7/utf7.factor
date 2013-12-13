USING:
    accessors
    arrays
    ascii
    assocs
    base64
    byte-arrays
    fry
    io
    io.encodings io.encodings.string io.encodings.utf16
    kernel
    sequences
    splitting
    strings ;
IN: io.encodings.utf7

SINGLETON: utf7
SINGLETON: utf7imap4

! This map encodes the difference between standard utf7 and the
! dialect used by IMAP which wants slashes repladed with commas when
! encoding and uses '&' instead of '+' as the escaping character.
CONSTANT: dialect-data {
    { utf7 { { "" "" } { "+" "-" } } }
    { utf7imap4 { { "/" "," } { "&" "-" } } }
}

: >raw-base64 ( byte-array -- str )
    >string utf16be encode >base64 [ CHAR: = = ] trim-tail ;

: flush-buffer ( buffer repl-pair surround-pair -- result )
    rot [ 2drop "" ] [
        >raw-base64 -rot [ first2 replace ] [ first2 surround ] bi*
    ] if-empty ;

: escaped-char ( str1 begin end -- str )
    -rot dupd = [ swap append ] [ nip ] if ;

: encode-utf7-char ( result buffer dialect-info ch -- result buffer )
    dup printable? [
        1string -rot first2
        [ flush-buffer swapd append swap ]
        [ nip first2 escaped-char append ] 2bi ""
    ] [ nip suffix ] if ;

: encode-utf7-string ( str dialect -- str' )
    { "" "" } swap dialect-data at [
        '[ [ first2 ] dip _ swap encode-utf7-char 2array ] reduce
    ] [
        [ first2 ] dip first2 flush-buffer append
    ] bi ;

: stream-write-utf7 ( string stream encoding -- )
    swapd encode-utf7-string >byte-array swap stream-write ;

M: utf7 encode-string stream-write-utf7 ;

M: utf7imap4 encode-string stream-write-utf7 ;
