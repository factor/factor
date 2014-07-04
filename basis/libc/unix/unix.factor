! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.strings destructors kernel libc system ;
IN: libc.unix

M: unix strerror ( errno -- str )
    [
        1024 [ malloc &free ] keep [ strerror_r ] 2keep drop nip
        alien>native-string
    ] with-destructors ;
