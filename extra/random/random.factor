! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel math namespaces sequences
io.backend io.binary combinators system vocabs.loader
random.backend random.mersenne-twister init ;
USE: prettyprint
IN: random

: random-bytes ( n -- r )
    [
        dup 4 rem zero? [ 1+ ] unless
        random-generator get random-bytes*
    ] keep head ;

: random ( seq -- elt )
    dup empty? [
        drop f
    ] [
        [
            length dup log2 7 + 8 /i
            random-bytes byte-array>bignum swap mod
        ] keep nth
    ] if ;

: random-bits ( n -- r ) 2^ random ;

: with-random ( tuple quot -- )
    random-generator swap with-variable ; inline

: with-secure-random ( quot -- )
    >r secure-random-generator get r> with-random ; inline

{
    { [ windows? ] [ "random.windows" require ] }
    { [ unix? ] [ "random.unix" require ] }
} cond

[
    [ 32 random-bits ] with-secure-random
    <mersenne-twister> random-generator set-global
] "random" add-init-hook
