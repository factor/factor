! Copyright (c) 2008 Eric Mertens.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math project-euler.common ;
IN: project-euler.215

! https://projecteuler.net/problem=215

! DESCRIPTION
! -----------

! Consider the problem of building a wall out of 2x1 and 3x1
! bricks (horizontal x vertical dimensions) such that, for extra
! strength, the gaps between horizontally-adjacent bricks never
! line up in consecutive layers, i.e. never form a "running
! crack".

! For example, the following 93 wall is not acceptable due to
! the running crack shown in red:

!     See problem site for image...

! There are eight ways of forming a crack-free 9x3 wall, written
! W(9,3) = 8.

! Calculate W(32,10).


! SOLUTION
! --------

<PRIVATE

TUPLE: block two three ;
TUPLE: end { ways integer } ;

C: <block> block
C: <end> end
: <failure> ( -- end ) 0 <end> ; inline
: <success> ( -- end ) 1 <end> ; inline

: failure? ( t -- ? ) ways>> 0 = ; inline

: choice ( t p q -- t t )
    [ [ two>> ] [ three>> ] bi ] 2dip bi* ; inline

GENERIC: merge ( t t -- t )
GENERIC#: block-merge 1 ( t t -- t )
GENERIC#: end-merge 1 ( t t -- t )
M: block merge block-merge ;
M: end   merge end-merge ;
M: block block-merge [ [ two>>   ] bi@ merge ]
                     [ [ three>> ] bi@ merge ] 2bi <block> ;
M: end   block-merge nip ;
M: block end-merge drop ;
M: end   end-merge [ ways>> ] bi@ + <end> ;

GENERIC: h-1 ( t -- t )
GENERIC: h0 ( t -- t )
GENERIC: h1 ( t -- t )
GENERIC: h2 ( t -- t )

M: block h-1 [ h1 ] [ h2 ] choice merge ;
M: block h0 drop <failure> ;
M: block h1 [ [ h1 ] [ h2 ] choice merge ]
            [ [ h0 ] [ h1 ] choice merge ] bi <block> ;
M: block h2 [ h1 ] [ h2 ] choice merge <failure> swap <block> ;

M: end h-1 drop <failure> ;
M: end h0 ;
M: end h1 drop <failure> ;
M: end h2 dup failure? [ <failure> <block> ] unless ;

: next-row ( t -- t ) [ h-1 ] [ h1 ] choice swap <block> ;

: first-row ( n -- t )
    [ <failure> <success> <failure> ] dip
    1 - [| a b c | b c <block> a b ] times 2drop ;

GENERIC: total ( t -- n )
M: block total [ total ] dup choice + ;
M: end   total ways>> ;

: solve ( width height -- ways )
    [ first-row ] dip 1 - [ next-row ] times total ;

PRIVATE>

: euler215 ( -- answer )
    32 10 solve ;

! [ euler215 ] 100 ave-time
! 208 ms ave run time - 9.06 SD (100 trials)

SOLUTION: euler215
