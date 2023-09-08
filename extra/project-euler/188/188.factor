! Copyright (c) 2009 Guillaume Nargeot.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions project-euler.common ;
IN: project-euler.188

! https://projecteuler.net/problem=188

! DESCRIPTION
! -----------

! The hyperexponentiation or tetration of a number a by a
! positive integer b, denoted by a↑↑b or ^(b)a, is recursively
! defined by:

! a↑↑1 = a,
! a↑↑(k+1) = a^(a↑↑k).

! Thus we have e.g. 3↑↑2 = 3^3 = 27, hence
! 3↑↑3 = 3^27 = 7625597484987 and
! 3↑↑4 is roughly 10^(3.6383346400240996*10^12).

! Find the last 8 digits of 1777↑↑1855.


! SOLUTION
! --------

! Using modular exponentiation.
! https://en.wikipedia.org/wiki/Modular_exponentiation

<PRIVATE

: hyper-exp-mod ( a b m -- e )
    1 rot [ [ 2dup ] dip swap ^mod ] times 2nip ;

PRIVATE>

: euler188 ( -- answer )
    1777 1855 10 8 ^ hyper-exp-mod ;

! [ euler188 ] 100 ave-time
! 4 ms ave run time - 0.05 SD (100 trials)

SOLUTION: euler188
