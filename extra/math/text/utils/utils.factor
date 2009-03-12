! Copyright (c) 2007, 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences ;
IN: math.text.utils

: 3digit-groups ( n -- seq )
    [ dup 0 > ] [ 1000 /mod ] produce nip ;
