! Copyright (C) 2009 Kye W. Shi.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.tuple kernel math math.functions
project-euler.common ranges sequences serialize ;
IN: project-euler.064

! http://projecteuler.net/problem=64

! DESCRIPTION
! -----------

! All square roots are periodic when written as continued
! fractions and can be written in the form:

! √N=a0+1/(a1+1/(a2+1/a3+...))

! For example, let us consider √23:

! √23=4+√(23)−4=4+1/(1/(√23−4)=4+1/(1+((√23−3)/7)

! If we continue we would get the following expansion:

! √23=4+1/(1+1/(3+1/(1+1/(8+...))))

! The process can be summarised as follows:

! a0=4, 1/(√23−4) = (√23+4)/7 = 1+(√23−3)/7
! a1=1, 7/(√23−3) = 7*(√23+3)/14 = 3+(√23−3)/2
! a2=3, 2/(√23−3) = 2*(√23+3)/14 = 1+(√23−4)/7
! a3=1, 7/(√23−4) = 7*(√23+4)/7 = 8+√23−4
! a4=8, 1/(√23−4) = (√23+4)/7 = 1+(√23−3)/7
! a5=1, 7/(√23−3) = 7*(√23+3)/14 = 3+(√23−3)/2
! a6=3, 2/(√23−3) = 2*(√23+3)/14 = 1+(√23−4)/7
! a7=1, 7/(√23−4) = 7*(√23+4)/7 = 8+√23−4

! It can be seen that the sequence is repeating. For
! conciseness, we use the notation √23=[4;(1,3,1,8)], to
! indicate that the block (1,3,1,8) repeats indefinitely.

! The first ten continued fraction representations of
! (irrational) square roots are:

! √2=[1;(2)] , period=1
! √3=[1;(1,2)], period=2
! √5=[2;(4)], period=1
! √6=[2;(2,4)], period=2
! √7=[2;(1,1,1,4)], period=4
! √8=[2;(1,4)], period=2
! √10=[3;(6)], period=1
! √11=[3;(3,6)], period=2
! √12=[3;(2,6)], period=2
! √13=[3;(1,1,1,1,6)], period=5

! Exactly four continued fractions, for N <= 13, have an odd period.

! How many continued fractions for N <= 10000 have an odd period?

<PRIVATE

TUPLE: cont-frac
    { whole integer }
    { num-const integer }
    { denom integer } ;

C: <cont-frac> cont-frac

: create-cont-frac ( n -- n cont-frac )
    dup sqrt >fixnum dup 1 <cont-frac> ;

: step ( n cont-frac -- n cont-frac )
    swap dup
    ! Store n
    [let :> n
        ! Extract the constant
        swap dup num-const>>
        :> num-const

        ! Find the new denominator
        num-const 2 ^ n swap -
        :> exp-denom

        ! Find the fraction in lowest terms
        dup denom>>
        exp-denom simple-gcd
        exp-denom swap /
        :> new-denom

        ! Find the new whole number
        num-const n sqrt + new-denom / >fixnum
        :> new-whole

        ! Find the new num-const
        num-const new-denom /
        new-whole swap -
        new-denom *
        :> new-num-const

        ! Finally, update the continuing fraction
        drop new-whole new-num-const new-denom <cont-frac>
    ] ;

:: loop ( c l n cf -- c l n cf )
    n cf step :> new-cf drop
    c 1 + l n new-cf
    l new-cf = [ loop ] unless ;

: find-period ( n -- period )
    0 swap
    create-cont-frac
    step
    dup deep-clone -rot
    loop
    drop drop drop ;

: try-all ( -- n )
    2 10000 [a..b]
    [ perfect-square? ] reject
    [ find-period ] map
    [ odd? ] filter
    length ;

PRIVATE>

: euler064a ( -- n ) try-all ;

<PRIVATE

! (√n + a)/b
TUPLE: cfrac n a b ;

C: <cfrac> cfrac

: >cfrac< ( fr -- n a b )
    [ n>> ] [ a>> ] [ b>> ] tri ;

! (√n + a) / b = 1 / (k + (√n + a') / b')
!
! b / (√n + a) = b (√n - a) / (n - a^2) = (√n - a) / ((n - a^2) / b)
:: reciprocal ( fr -- fr' )
    fr >cfrac< :> ( n a b )
    n
    a neg
    n a sq - b /
    <cfrac> ;

:: split ( fr -- k fr' )
    fr >cfrac< :> ( n a b )
    n sqrt a + b /i
    dup n swap
    b * a swap -
    b
    <cfrac> ;

: pure ( n -- fr )
    0 1 <cfrac> ;

: next ( fr -- fr' )
    reciprocal split nip ;

:: period ( n -- period )
    n sqrt >integer sq n = [ 0 ] [
        n pure split nip :> start
        1 start next
        [ dup start = not ]
        [ next [ 1 + ] dip ]
        while drop
    ] if ;

PRIVATE>

: euler064b ( -- ct )
    10000 [1..b] [ period odd? ] count ;

SOLUTION: euler064b
