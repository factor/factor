! Copyright (C) 2008 Doug Coleman, Slava Pestov, Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit kernel math math.constants math.functions
    math.vectors sequences ;
IN: math.analysis

<PRIVATE

! http://www.rskey.org/gamma.htm  "Lanczos Approximation"
! n=6: error ~ 3 x 10^-11

CONSTANT: gamma-g6 5.15

CONSTANT: gamma-p6
    {
        2.50662827563479526904 225.525584619175212544 -268.295973841304927459
        80.9030806934622512966 -5.00757863970517583837 0.0114684895434781459556
    }

: gamma-z ( x n -- seq )
    [ + recip ] with map 1.0 0 pick set-nth ;

: (gamma-lanczos6) ( x -- log[gamma[x+1]] )
    #! log(gamma(x+1)
    [ 0.5 + dup gamma-g6 + [ log * ] keep - ]
    [ 6 gamma-z gamma-p6 v. log ] bi + ;

: gamma-lanczos6 ( x -- gamma[x] )
    #! gamma(x) = gamma(x+1) / x
    [ (gamma-lanczos6) exp ] keep / ;

: gammaln-lanczos6 ( x -- gammaln[x] )
    #! log(gamma(x)) = log(gamma(x+1)) - log(x)
    [ (gamma-lanczos6) ] keep log - ;

: gamma-neg ( gamma[abs[x]] x -- gamma[x] )
    dup pi * sin * * pi neg swap / ; inline

PRIVATE>

: gamma ( x -- y )
    #! gamma(x) = integral 0..inf [ t^(x-1) exp(-t) ] dt
    #! gamma(n+1) = n! for n > 0
    dup { [ 0.0 <= ] [ 1.0 mod zero? ] } 1&& [
        drop 1./0.
    ] [
        [ abs gamma-lanczos6 ] keep dup 0 > [ drop ] [ gamma-neg ] if
    ] if ;

: gammaln ( x -- gamma[x] )
    #! gammaln(x) is an alternative when gamma(x)'s range
    #! varies too widely
    dup 0 < [
        drop 1./0.
    ] [
        [ abs gammaln-lanczos6 ] keep dup 0 > [ drop ] [ gamma-neg ] if
    ] if ;

: nth-root ( n x -- y )
    swap recip ^ ;

! Forth Scientific Library Algorithm #1
!
! Evaluates the Real Exponential Integral,
!     E1(x) = - Ei(-x) =   int_x^\infty exp^{-u}/u du      for x > 0
! using a rational approximation
!
! Collected Algorithms from ACM, Volume 1 Algorithms 1-220,
! 1980; Association for Computing Machinery Inc., New York,
! ISBN 0-89791-017-6
!
! (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
! author to use this software for any application provided the
! copyright notice is preserved.

: exp-int ( x -- y )
    #! For real values of x only. Accurate to 7 decimals.
    dup 1.0 < [
        dup 0.00107857 * 0.00976004 -
        over *
        0.05519968 +
        over *
        0.24991055 -
        over *
        0.99999193 +
        over *
        0.57721566 -
        swap log -
    ] [
        dup 8.5733287401 +
        over *
        18.059016973 +
        over *
        8.6347608925 +
        over *
        0.2677737343 +

        over
        dup 9.5733223454 +
        over *
        25.6329561486 +
        over *
        21.0996530827 +
        over *
        3.9584969228 +

        nip
        /
        over /
        swap -1.0 * exp
        *
    ] if ;

! James Stirling's approximation for N!:
! http://www.csse.monash.edu.au/~lloyd/tildeAlgDS/Numerical/Stirling/

: stirling-fact ( n -- fact )
    [ pi 2 * * sqrt ]
    [ [ e / ] keep ^ ]
    [ 12 * recip 1+ ] tri * * ;

