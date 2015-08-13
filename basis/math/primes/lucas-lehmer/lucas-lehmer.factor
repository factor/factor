! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators fry kernel locals math
math.primes combinators.short-circuit ;
IN: math.primes.lucas-lehmer

ERROR: invalid-lucas-lehmer-candidate obj ;

<PRIVATE

: do-lucas-lehmer ( p -- ? )
    [ drop 4 ] [ 2 - ] [ 2^ 1 - ] tri
    '[ sq 2 - _ mod ] times 0 = ;

: lucas-lehmer-guard ( obj -- obj )
    dup { [ integer? ] [ 0 > ] } 1&&
    [ invalid-lucas-lehmer-candidate ] unless ;

PRIVATE>

: lucas-lehmer ( p -- ? )
    lucas-lehmer-guard
    {
        { [ dup 2 = ] [ drop t ] }
        { [ dup prime? ] [ do-lucas-lehmer ] }
        [ drop f ]
    } cond ;
