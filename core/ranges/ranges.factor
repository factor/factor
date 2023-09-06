! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.algebra classes.tuple kernel locals
math nath.functions math.order sequences sequences.private
sets sorting ;
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

<PRIVATE

: twiddle ( a b -- a b step ) 2dup > -1 1 ? ; inline

: (a.. ( a b step -- a' b' step ) dup [ + ] curry 2dip ; inline

: ..b) ( a b step -- a' b' step ) dup [ - ] curry dip ; inline

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
M: range in?
    over number?
    [ [ from>> ] [ step>> ] [ length>> 1 - ] tri
        [ * over + sort-pair between? ] 4keep
        drop 3dup [ - ] dip /i * + = and
    ] [ 2drop f ] if ;

M: range cardinality length>> ;

M: range all-unique? drop t ;

M: range duplicates drop f ;

<PRIVATE

: start-stop-step>> ( range -- start stop step )
    [ from>> ] [ step>> ]
    [ length>> 1 - 2over swapd * + ] tri swap ;

: rev-range ( range -- range' )
    start-stop-step>> neg swapd <range> ;

: abs-step ( range -- range' )
    dup step>> neg? [ rev-range ] when ; inline

: empty-range ( -- range ) 1 0 1 <range> ;

! https://github.com/JuliaLang/julia/blob/8e14322b5aa344639dd86bf9eabb84afe831fcba/base/range.jl#L1185
:: (intersect) ( range1 range2 -- range' )
    range1 empty? range2 empty? or [ empty-range ] [
        
        range1 abs-step start-stop-step>> :> ( start1 stop1 step1 )
        range2 abs-step start-stop-step>> :> ( start2 stop2 step2 )

        step1 step2 lcm :> a
        step1 step2 gcd :> ( x g )

        start1 start2 - g /mod :> ( z y )

        y zero? not [ empty-range ] [
        
        start1 x z step1 * * - :> b

        start1 start2 [ b over - a rem + ] bi@ max :> m
        stop1  stop2  [  dup b - a rem - ] bi@ min :> n

        m n a <range>
    ] if ] if ;
    
PRIVATE>

M: range intersect
    over range? [ (intersect) ] [ call-next-method ] if ;

M: range intersects?
    over range?
    [ intersect length>> zero? not ]
    [ call-next-method ] if ;

M: range set=
    over range?
    [ [ abs-step ] bi@ = ]
    [ call-next-method ] if ;

M: range subset?
    swap [ drop t ] [ swap over range?
        [ dupd (intersect) = ] [ call-next-method ] if
    ] if-empty ;