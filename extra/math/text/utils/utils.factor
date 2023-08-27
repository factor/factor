! Copyright (c) 2007, 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions sequences ;
IN: math.text.utils

: digit-groups ( n k -- seq )
    [ dup 0 > ] swap '[ _ 10^ /mod ] produce nip ;
