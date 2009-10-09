! Copyright (C) 2009 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: project-euler.common math kernel sequences math.functions math.ranges prettyprint io threads math.parser locals arrays namespaces ;
IN: project-euler.255

! http://projecteuler.net/index.php?section=problems&id=255

! DESCRIPTION
! -----------
! We define the rounded-square-root of a positive integer n as the square root of n rounded to the nearest integer.
! 
! The following procedure (essentially Heron's method adapted to integer arithmetic) finds the rounded-square-root of n:
! 
! Let d be the number of digits of the number n.
! If d is odd, set x_(0) = 2×10^((d-1)⁄2).
! If d is even, set x_(0) = 7×10^((d-2)⁄2).
! Repeat:
! 
! until x_(k+1) = x_(k).
! 
! As an example, let us find the rounded-square-root of n = 4321.
! n has 4 digits, so x_(0) = 7×10^((4-2)⁄2) = 70.
! 
! Since x_(2) = x_(1), we stop here.
! So, after just two iterations, we have found that the rounded-square-root of 4321 is 66 (the actual square root is 65.7343137…).
! 
! The number of iterations required when using this method is surprisingly low.
! For example, we can find the rounded-square-root of a 5-digit integer (10,000 ≤ n ≤ 99,999) with an average of 3.2102888889 iterations (the average value was rounded to 10 decimal places).
! 
! Using the procedure described above, what is the average number of iterations required to find the rounded-square-root of a 14-digit number (10^(13) ≤ n < 10^(14))?
! Give your answer rounded to 10 decimal places.
! 
! Note: The symbols ⌊x⌋ and ⌈x⌉ represent the floor function and ceiling function respectively.
! 
<PRIVATE

: round-to-10-decimals ( a -- b ) 1.0e10 * round 1.0e10 / ;

! same as produce, but outputs the sum instead of the sequence of results
: produce-sum ( id pred quot -- sum )
    [ 0 ] 2dip [ [ dip swap ] curry ] [ [ dip + ] curry ] bi* while ; inline

: x0 ( i -- x0 )
    number-length dup even? 
    [ 2 - 2 / 10 swap ^ 7 * ]
    [ 1 - 2 / 10 swap ^ 2 * ] if ;
: ⌈a/b⌉  ( a b -- ⌈a/b⌉ )
    [ 1 - + ] keep /i ;

: xk+1 ( n xk -- xk+1 )
    [ ⌈a/b⌉ ] keep + 2 /i ;

: next-multiple ( a multiple -- next )
    [ [ 1 - ] dip /i 1 + ] keep * ;

DEFER: iteration#
! Gives the number of iterations when xk+1 has the same value for all a<=i<=n
:: (iteration#) ( i xi a b -- # )
    a xi xk+1 dup xi = 
        [ drop i b a - 1 + * ] 
        [ i 1 + swap a b iteration# ] if ;

! Gives the number of iterations in the general case by breaking into intervals
! in which xk+1 is the same.
:: iteration# ( i xi a b -- # )
    a 
    a xi next-multiple 
    [ dup b < ] 
    [ 
        ! set up the values for the next iteration
        [ nip [ 1 + ] [ xi + ] bi ] 2keep
        ! set up the arguments for (iteration#)
        [ i xi ] 2dip (iteration#) 
    ] produce-sum 
    ! deal with the last numbers
    [ drop b [ i xi ] 2dip (iteration#) ] dip
    + ;

: 10^ ( a -- 10^a ) 10 swap ^ ; inline

: (euler255) ( a b -- answer ) 
    [ 10^ ] bi@ 1 -
    [ [ drop x0 1 swap ] 2keep iteration# ] 2keep
    swap - 1 + /f ;


PRIVATE>

: euler255 ( -- answer ) 
    13 14 (euler255) round-to-10-decimals ;

SOLUTION: euler255

