! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators effects.parser kernel
literals math random sequences ;
IN: random.data

<<
CONSTANT: digits-count 10
CONSTANT: letters-count 26
>>

: random-digit ( -- ch )
    digits-count random CHAR: 0 + ;

: random-LETTER ( -- ch ) letters-count random CHAR: A + ;

: random-letter ( -- ch ) letters-count random CHAR: a + ;

: random-Letter ( -- ch )
    { random-LETTER random-letter } random execute( -- ch ) ;

CONSTANT: digit-probability $[ letters-count 2 * digits-count / 1 + recip ]
: random-ch ( -- ch )
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" random ;

: random-string ( n -- string ) [ random-ch ] "" replicate-as ;
