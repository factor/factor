! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: alien.c-types alien.syntax kernel random ;

IN: random.c

LIBRARY: libc

FUNCTION: int rand ( )

SINGLETON: c-random

M: c-random random-32* drop rand ;

: with-c-random ( quot -- )
    [ c-random ] dip with-random ; inline
