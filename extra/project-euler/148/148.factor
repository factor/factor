! Copyright (c) 2008 Eric Mertens
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions sequences sequences.lib ;

IN: project-euler.148

<PRIVATE

: sum-1toN ( n -- sum )
    dup 1+ * 2/ ; inline

: >base7 ( x -- y )
    [ dup 0 > ] [ 7 /mod ] [ ] produce nip ;

: (use-digit) ( prev x index -- next )
    [ [ 1+ * ] [ sum-1toN 7 sum-1toN ] bi ] dip ^ * + ;

PRIVATE>

: (euler148) ( x -- y )
    >base7 0 [ (use-digit) ] reduce-index ;

: euler148 ( -- y )
    10 9 ^ (euler148) ;
