! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: alien.c-types alien.syntax kernel math math.bitwise random ;

IN: random.c

LIBRARY: libc

FUNCTION: int rand ( )

SINGLETON: c-random

M: c-random random-32*
    drop
    rand 15 bits 17 shift
    rand 15 bits 2 shift +
    rand 2 bits + ;

: with-c-random ( quot -- )
    [ c-random ] dip with-random ; inline

INSTANCE: c-random base-random
