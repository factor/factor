! Copyright (c) 2009 Guillaume Nargeot.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math project-euler.common sequences sorting ;
IN: project-euler.112

! https://projecteuler.net/problem=112

! DESCRIPTION
! -----------

! Working from left-to-right if no digit is exceeded by the
! digit to its left it is called an increasing number; for
! example, 134468.

! Similarly if no digit is exceeded by the digit to its right it
! is called a decreasing number; for example, 66420.

! We shall call a positive integer that is neither increasing
! nor decreasing a "bouncy" number; for example, 155349.

! Clearly there cannot be any bouncy numbers below one-hundred,
! but just over half of the numbers below one-thousand (525) are
! bouncy. In fact, the least number for which the proportion of
! bouncy numbers first reaches 50% is 538.

! Surprisingly, bouncy numbers become more and more common and
! by the time we reach 21780 the proportion of bouncy numbers is
! equal to 90%.

! Find the least number for which the proportion of bouncy
! numbers is exactly 99%.


! SOLUTION
! --------

<PRIVATE

: bouncy? ( n -- ? )
    number>digits dup sort
    [ = not ] [ reverse = not ] 2bi and ;

PRIVATE>

: euler112 ( -- answer )
    0 0 0 [
        2dup swap 99 * = not
    ] [
        [ 1 + ] 2dip pick bouncy? [ 1 + ] [ [ 1 + ] dip ] if
    ] do while 2drop ;

! [ euler112 ] 100 ave-time
! 2749 ms ave run time - 33.76 SD (100 trials)

SOLUTION: euler112
