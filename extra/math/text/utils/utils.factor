! Copyright (c) 2007, 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel fry math.functions math sequences ;
IN: math.text.utils

: digit-groups ( n k -- seq )
    [ dup 0 > ] swap '[ _ 10^ /mod ] produce nip ;
