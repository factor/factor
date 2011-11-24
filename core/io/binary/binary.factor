! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences ;
IN: io.binary

: le> ( seq -- x ) dup length iota 0 [ 8 * shift + ] 2reduce ;
: be> ( seq -- x ) 0 [ [ 8 shift ] dip + ] reduce ;

: mask-byte ( x -- y ) 0xff bitand ; inline

: nth-byte ( x n -- b ) -8 * shift mask-byte ; inline

: >le ( x n -- byte-array ) iota [ nth-byte ] with B{ } map-as ;
: >be ( x n -- byte-array ) >le reverse! ;

: d>w/w ( d -- w1 w2 )
    [ 0xffffffff bitand ]
    [ -32 shift 0xffffffff bitand ] bi ;

: w>h/h ( w -- h1 h2 )
    [ 0xffff bitand ]
    [ -16 shift 0xffff bitand ] bi ;

: h>b/b ( h -- b1 b2 )
    [ mask-byte ]
    [ -8 shift mask-byte ] bi ;

: signed-le> ( bytes -- x )
    [ le> ] [ length 8 * 1 - 2^ 1 - ] bi
    2dup > [ bitnot bitor ] [ drop ] if ;

: signed-be> ( bytes -- x )
    <reversed> signed-le> ;
