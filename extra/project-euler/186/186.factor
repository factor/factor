! Copyright (c) 2008 Eric Mertens.
! See http://factorcode.org/license.txt for BSD license.
USING: circular disjoint-sets kernel math math.ranges sequences project-euler.common ;
IN: project-euler.186

! http://projecteuler.net/index.php?section=problems&id=186

! DESCRIPTION
! -----------

! Here are the records from a busy telephone system with one million users:

!     RecNr  Caller  Called
!     1      200007  100053
!     2      600183  500439
!     3      600863  701497
!     ...    ...     ...

! The telephone number of the caller and the called number in record n are
! Caller(n) = S2n-1 and Called(n) = S2n where S1,2,3,... come from the "Lagged
! Fibonacci Generator":

! For 1 <= k <= 55, Sk = [100003 - 200003k + 300007k^3] (modulo 1000000)
! For 56 <= k, Sk = [Sk-24 + Sk-55] (modulo 1000000)

! If Caller(n) = Called(n) then the user is assumed to have misdialled and the
! call fails; otherwise the call is successful.

! From the start of the records, we say that any pair of users X and Y are
! friends if X calls Y or vice-versa. Similarly, X is a friend of a friend of Z
! if X is a friend of Y and Y is a friend of Z; and so on for longer chains.

! The Prime Minister's phone number is 524287. After how many successful calls,
! not counting misdials, will 99% of the users (including the PM) be a friend,
! or a friend of a friend etc., of the Prime Minister?


! SOLUTION
! --------

: (generator) ( k -- n )
    dup sq 300007 * 200003 - * 100003 + 1000000 rem ;

: <generator> ( -- lag )
    55 [1,b] [ (generator) ] map <circular> ;

: advance ( lag -- )
    [ { 0 31 } swap nths sum 1000000 rem ] keep push-circular ;

: next ( lag -- n )
    [ first ] [ advance ] bi ;

: 2unless? ( x y ?quot quot -- )
    [ 2keep rot [ 2drop ] ] dip if ; inline

: (p186) ( generator counter unionfind -- counter )
    524287 over equiv-set-size 990000 < [
        pick [ next ] [ next ] bi
        [ = ] [
            pick equate
            [ 1 + ] dip
        ] 2unless? (p186)
    ] [
        drop nip
    ] if ;

: <relation> ( n -- unionfind )
    <disjoint-set> [ [ add-atom ] curry each ] keep ;

: euler186 ( -- n )
    <generator> 0 1000000 <relation> (p186) ;

! [ euler186 ] 10 ave-time
! 18572 ms ave run time - 796.87 SD (10 trials)

SOLUTION: euler186
