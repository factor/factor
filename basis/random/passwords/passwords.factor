! Copyright (C) 2019 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: fry literals ranges random sequences ;
IN: random.passwords

<PRIVATE

CONSTANT: ascii-printable-charset $[ 33 126 [a..b] ]
CONSTANT: hex-charset "0123456789ABCDEF"
CONSTANT: alphanum-charset $[
    CHAR: 0 CHAR: 9 [a..b]
    CHAR: a CHAR: z [a..b] append
    CHAR: A CHAR: Z [a..b] append ]

PRIVATE>

: password ( n charset -- string )
    '[ [ _ random ] "" replicate-as ] with-secure-random ;

: ascii-password ( n -- string )
    ascii-printable-charset password ;

: hex-password ( n -- string )
    hex-charset password ;

: alnum-password ( n -- string )
    alphanum-charset password ;
