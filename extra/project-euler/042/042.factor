! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: ascii io.encodings.ascii io.files kernel make math
math.functions project-euler.common sequences splitting ;
IN: project-euler.042

! https://projecteuler.net/problem=42

! DESCRIPTION
! -----------

! The nth term of the sequence of triangle numbers is given by,
! tn = n * (n + 1) / 2; so the first ten triangle numbers are:

!     1, 3, 6, 10, 15, 21, 28, 36, 45, 55, ...

! By converting each letter in a word to a number corresponding
! to its alphabetical position and adding these values we form a
! word value. For example, the word value for SKY is 19 + 11 +
! 25 = 55 = t10. If the word value is a triangle number then we
! shall call the word a triangle word.

! Using words.txt (right click and 'Save Link/Target As...'), a
! 16K text file containing nearly two-thousand common English
! words, how many are triangle words?


! SOLUTION
! --------

<PRIVATE

: source-042 ( -- seq )
    "resource:extra/project-euler/042/words.txt"
    ascii file-contents [ quotable? ] filter "," split ;

: (triangle-upto) ( limit n -- )
    2dup nth-triangle > [
        dup nth-triangle , 1 + (triangle-upto)
    ] [
        2drop
    ] if ;

: triangle-upto ( n -- seq )
    [ 1 (triangle-upto) ] { } make ;

PRIVATE>

: euler042 ( -- answer )
    source-042 [ alpha-value ] map dup supremum
    triangle-upto [ member? ] curry count ;

! [ euler042 ] 100 ave-time
! 19 ms ave run time - 1.97 SD (100 trials)


! ALTERNATE SOLUTIONS
! -------------------

! Use the inverse function of n * (n + 1) / 2 and test if the result is an integer

<PRIVATE

: triangle? ( n -- ? )
    8 * 1 + sqrt 1 - 2 / 1 mod zero? ;

PRIVATE>

: euler042a ( -- answer )
    source-042 [ alpha-value ] map [ triangle? ] count ;

! [ euler042a ] 100 ave-time
! 21 ms ave run time - 2.2 SD (100 trials)

SOLUTION: euler042a
