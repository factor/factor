! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences ;
IN: io.binary

: le> ( seq -- x ) B{ } like byte-array>bignum ;
: be> ( seq -- x ) <reversed> le> ;

: mask-byte ( x -- y ) HEX: ff bitand ; inline

: nth-byte ( x n -- b ) -8 * shift mask-byte ; inline

: >le ( x n -- str ) [ nth-byte ] curry* "" map-as ;
: >be ( x n -- str ) >le dup reverse-here ;

: d>w/w ( d -- w1 w2 )
    dup HEX: ffffffff bitand
    swap -32 shift HEX: ffffffff bitand ;

: w>h/h ( w -- h1 h2 )
    dup HEX: ffff bitand
    swap -16 shift HEX: ffff bitand ;

: h>b/b ( h -- b1 b2 )
    dup mask-byte
    swap -8 shift mask-byte ;
