! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences ;
IN: io.binary

: le> ( seq -- x ) 0 [ 8 * shift + ] reduce-index ;

: be> ( seq -- x ) 0 [ [ 8 shift ] dip + ] reduce ;

: mask-byte ( x -- y ) 0xff bitand ; inline

: nth-byte ( x n -- b ) -8 * shift mask-byte ; inline

<PRIVATE

: map-bytes ( x seq -- byte-array )
    [ nth-byte ] with B{ } map-as ; inline

PRIVATE>

: >le ( x n -- byte-array ) <iota> map-bytes ;

: >be ( x n -- byte-array ) <iota> <reversed> map-bytes ;

: d>w/w ( d -- w1 w2 )
    [ 0xffffffff bitand ] [ -32 shift 0xffffffff bitand ] bi ;

: w>h/h ( w -- h1 h2 )
    [ 0xffff bitand ] [ -16 shift 0xffff bitand ] bi ;

: h>b/b ( h -- b1 b2 )
    [ mask-byte ] [ -8 shift mask-byte ] bi ;

<PRIVATE

: signed> ( x seq -- n )
    length 8 * 2dup 1 - bit? [ 2^ - ] [ drop ] if ; inline

PRIVATE>

: signed-le> ( bytes -- x ) [ le> ] [ signed> ] bi ;

: signed-be> ( bytes -- x ) [ be> ] [ signed> ] bi ;
