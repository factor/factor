! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators effects.parser kernel math random
combinators.random sequences ;
IN: random.data

: random-digit ( -- ch )
    10 random CHAR: 0 + ;

: random-LETTER ( -- ch ) 26 random CHAR: A + ;

: random-letter ( -- ch ) 26 random CHAR: a + ;

: random-Letter ( -- ch )
    { random-LETTER  random-letter } execute-random ;

: random-ch ( -- ch )
    { random-digit random-Letter } execute-random ;

: random-string ( n -- string ) [ random-ch ] "" replicate-as ;
