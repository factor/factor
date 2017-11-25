! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes.tuple kernel math math.order sequences
sequences.private ;
IN: math.ranges

TUPLE: range
{ from read-only }
{ length read-only }
{ step read-only } ;

<PRIVATE

: sign/mod ( x y -- z w )
    [ [ /i ] 2keep pick * - ] keep 0 < [ neg ] when ; inline

PRIVATE>

: <range> ( a b step -- range )
    [ over - ] dip
    [ sign/mod 0 < [ 1 + ] unless 0 max ] keep
    range boa ; inline

M: range length ( seq -- n ) length>> ; inline

M: range nth-unsafe ( n range -- obj )
    [ step>> * ] keep from>> + ; inline

! We want M\ tuple hashcode, not M\ sequence hashcode here!
! sequences hashcode is O(n) in number of elements
M: range hashcode* tuple-hashcode ;

INSTANCE: range immutable-sequence

M: range sum [ length ] [ first ] [ last ] tri + * 2 / ;

<PRIVATE

: twiddle ( a b -- a b step ) 2dup > -1 1 ? ; inline

: (a, ( a b step -- a' b' step ) dup [ + ] curry 2dip ; inline

: ,b) ( a b step -- a' b' step ) dup [ - ] curry dip ; inline

PRIVATE>

: [a,b] ( a b -- range ) twiddle <range> ; inline

: (a,b] ( a b -- range ) twiddle (a, <range> ; inline

: [a,b) ( a b -- range ) twiddle ,b) <range> ; inline

: (a,b) ( a b -- range ) twiddle (a, ,b) <range> ; inline

: [0,b] ( b -- range ) 0 swap [a,b] ; inline

: [1,b] ( b -- range ) 1 swap [a,b] ; inline

: [0,b) ( b -- range ) 0 swap [a,b) ; inline

: [1,b) ( b -- range ) 1 swap [a,b) ; inline
