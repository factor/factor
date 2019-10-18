! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences ;
IN: io.binary

: le> ( seq -- x ) B{ } like byte-array>bignum >integer ;
: be> ( seq -- x ) <reversed> le> ;

: mask-byte ( x -- y ) HEX: ff bitand ; inline

: nth-byte ( x n -- b ) -8 * shift mask-byte ; inline

: >le ( x n -- byte-array ) iota [ nth-byte ] with B{ } map-as ;
: >be ( x n -- byte-array ) >le reverse! ;

: d>w/w ( d -- w1 w2 )
    [ HEX: ffffffff bitand ]
    [ -32 shift HEX: ffffffff bitand ] bi ;

: w>h/h ( w -- h1 h2 )
    [ HEX: ffff bitand ]
    [ -16 shift HEX: ffff bitand ] bi ;

: h>b/b ( h -- b1 b2 )
    [ mask-byte ]
    [ -8 shift mask-byte ] bi ;

: signed-le> ( bytes -- x )
    [ le> ] [ length 8 * 1 - 2^ 1 - ] bi
    2dup > [ bitnot bitor ] [ drop ] if ;

: signed-be> ( bytes -- x )
    <reversed> signed-le> ;
