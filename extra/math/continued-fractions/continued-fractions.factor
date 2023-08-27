! Copyright (C) 2009 Samuel Tardieu.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions sequences vectors ;
IN: math.continued-fractions

<PRIVATE

: split-float ( f -- d i )
    dup >integer [ - ] keep ;

: closest ( seq -- newseq )
    unclip-last round >integer suffix ;

PRIVATE>

: next-approx ( seq -- )
    dup [ pop split-float ] [ push ] bi
    [ drop ] [ recip swap push ] if-zero ;

: >ratio ( seq -- a/b )
    closest reverse! unclip-slice [ swap recip + ] reduce ;

: approx ( epsilon float -- a/b )
    dup 1vector
    [ 3dup >ratio - abs < ] [ dup next-approx ] while
    2nip >ratio ;
