! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: combinators.short-circuit kernel make math sequences ;

IN: leb128

:: >leb128 ( n -- byte-array )
    [
        n [
            [ -7 shift dup ] [ 0x7f bitand ] bi :> ( i b )
            {
                [ i zero? b 6 bit? not and ]
                [ i -1 = b 6 bit? and ]
            } 0|| [ f b ] [ t b 0x80 bitor ] if ,
        ] loop drop
    ] B{ } make ;

: leb128> ( byte-array -- n )
    [ 0 [ [ 0x7f bitand ] [ 7 * shift ] bi* + ] reduce-index ] keep
    dup last 6 bit? [ length 7 * 2^ neg bitor ] [ drop ] if ;
