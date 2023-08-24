! Copyright (c) 2007 Samuel Tardieu.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators kernel math math.parser project-euler.common
sequences ;
IN: project-euler.175

! https://projecteuler.net/index.php?section=problems&id=175

! DESCRIPTION
! -----------

! Define f(0) = 1 and f(n) to be the number of ways to write n as a sum of
! powers of 2 where no power occurs more than twice.

! For example, f(10) = 5 since there are five different ways to express
! 10: 10 = 8+2 = 8+1+1 = 4+4+2 = 4+2+2+1+1 = 4+4+1+1

! It can be shown that for every fraction p/q (p0, q0) there exists at least
! one integer n such that f(n) / f(n-1) = p/q.

! For instance, the smallest n for which f(n) / f(n-1) = 13/17 is 241. The
! binary expansion of 241 is 11110001. Reading this binary number from the most
! significant bit to the least significant bit there are 4 one's, 3 zeroes and
! 1 one. We shall call the string 4,3,1 the Shortened Binary Expansion of 241.

! Find the Shortened Binary Expansion of the smallest n for which
! f(n) / f(n-1) = 123456789/987654321.

! Give your answer as comma separated integers, without any whitespaces.


! SOLUTION
! --------

<PRIVATE

: add-bits ( vec n b -- )
    over zero? [
        3drop
    ] [
        pick length 1 bitand = [ over pop + ] when swap push
    ] if ;

: compute ( vec ratio -- )
    {
        { [ dup integer? ] [ 1 - 0 add-bits ] }
        { [ dup 1 < ] [ 1 over - / dupd compute 1 1 add-bits ] }
        [ [ 1 mod compute ] 2keep >integer 0 add-bits ]
    } cond ;

PRIVATE>

: euler175 ( -- result )
    V{ 1 } clone dup 123456789/987654321 compute [ number>string ] map "," join ;

! [ euler175 ] 100 ave-time
! 0 ms ave run time - 0.31 SD (100 trials)

SOLUTION: euler175
