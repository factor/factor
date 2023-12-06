! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.algebra classes.tuple kernel
math math.order parser sequences sequences.private sets sorting ;
IN: ranges

TUPLE: range
{ from number read-only }
{ length integer read-only }
{ step number read-only } ;

<PRIVATE

: sign/mod ( x y -- z w )
    [ [ /i ] 2keep pick * - ] keep 0 < [ neg ] when ; inline

PRIVATE>

: <range> ( a b step -- range )
    [ over - ] dip
    [ sign/mod 0 < [ 1 + ] unless 0 max ] keep
    range boa ; inline

: >range< ( range -- start stop step )
    [ from>> ] [ length>> ] [ step>> ] tri [ swap 1 - * over + ] keep ;

M: range length length>> ; inline

M: range nth-unsafe
    [ step>> * ] keep from>> + ; inline

! We want M\ tuple hashcode, not M\ sequence hashcode here!
! sequences hashcode is O(n) in number of elements
M: range hashcode* tuple-hashcode ;

INSTANCE: range immutable-sequence

M: range sum
    dup length
    [ drop 0 ]
    [ swap [ first-unsafe ] [ last-unsafe ] bi + * 2 / ] if-zero ;

M: range minimum
    dup step>> 0 > [ first ] [ last ] if ;

M: range maximum
    dup step>> 0 > [ last ] [ first ] if ;

<PRIVATE

: twiddle ( a b -- a b step ) 2dup > -1 1 ? ; inline

: (a.. ( a b step -- a' b' step ) dup [ + ] curry 2dip ; inline

: ..b) ( a b step -- a' b' step )
    2over - over mod zero? [ dup [ - ] curry dip ] when ; inline

PRIVATE>

: [a..b] ( a b -- range ) twiddle <range> ; inline

: (a..b] ( a b -- range ) twiddle (a.. <range> ; inline

: [a..b) ( a b -- range ) twiddle ..b) <range> ; inline

: (a..b) ( a b -- range ) twiddle (a.. ..b) <range> ; inline

: [0..b] ( b -- range ) 0 swap [a..b] ; inline

: [1..b] ( b -- range ) 1 swap [a..b] ; inline

: [0..b) ( b -- range ) 0 swap [a..b) ; inline

: [1..b) ( b -- range ) 1 swap [a..b) ; inline

! Some methods can be much faster for ranges

<PRIVATE

: >forward-range< ( range -- start stop step )
    >range< dup neg? [ abs swapd ] when ;

: forward-range ( range -- range' )
    >forward-range< <range> ; inline

CONSTANT: empty-range T{ range f 1 0 1 }

:: intersect-range ( range1 range2 -- range3 )
    range1 empty? range2 empty? or [ empty-range ] [
        range1 >forward-range< :> ( start1 stop1 step1 )
        range2 >forward-range< :> ( start2 stop2 step2 )
        step1 step2 gcd :> ( x g )
        start1 start2 - g /mod :> ( z y )
        y zero? not [ empty-range ] [
            start1 x z step1 * * - :> b
            step1 step2 lcm :> a
            start1 start2 [ b over - a rem + ] bi@ max :> m
            stop1  stop2  [  dup b - a rem - ] bi@ min :> n
            m n a <range>
        ] if
    ] if ;

PRIVATE>

M: range in?
    over number? [
        >forward-range< [ 3dup between? ] dip swap
        [ nip 3dup [ - ] dip /i * + = ] [ 4drop f ] if
    ] [ 2drop f ] if ;

M: range cardinality length>> ;

M: range all-unique? drop t ;

M: range duplicates drop f ;

M: range members >array ; ! XXX: just return a T{ range } ? ;

M: range intersect
    over range? [ intersect-range ] [ call-next-method ] if ;

M: range intersects?
    over range?
    [ intersect-range length>> zero? not ]
    [ call-next-method ] if ;

M: range set=
    over range?
    [ [ [ empty-range ] [ forward-range ] if-empty ] bi@ = ]
    [ call-next-method ] if ;

M: range subset?
    over range?
    [ over empty? [ 2drop t ] [ dupd intersect-range = ] if ]
    [ call-next-method ] if ;

SYNTAX: ..= dup pop scan-object [a..b] suffix! ;

SYNTAX: ..< dup pop scan-object [a..b) suffix! ;
