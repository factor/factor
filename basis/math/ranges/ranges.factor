! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel layouts math math.order namespaces sequences
sequences.private accessors classes.tuple arrays ;
IN: math.ranges

TUPLE: range
{ from read-only }
{ length read-only }
{ step read-only } ;

: <range> ( a b step -- range )
    [ over - ] dip [ /i 1 + 0 max ] keep range boa ; inline

M: range length ( seq -- n )
    length>> ;

M: range nth-unsafe ( n range -- obj )
    [ step>> * ] keep from>> + ;

! For ranges with many elements, the default element-wise methods
! sequences define are unsuitable because they're O(n)
M: range equal? over range? [ tuple= ] [ 2drop f ] if ;

M: range hashcode* tuple-hashcode ;

INSTANCE: range immutable-sequence

: twiddle ( a b -- a b step ) 2dup > -1 1 ? ; inline

: (a, ( a b step -- a' b' step ) dup [ + ] curry 2dip ; inline

: ,b) ( a b step -- a' b' step ) dup [ - ] curry dip ; inline

: [a,b] ( a b -- range ) twiddle <range> ; inline

: (a,b] ( a b -- range ) twiddle (a, <range> ; inline

: [a,b) ( a b -- range ) twiddle ,b) <range> ; inline

: (a,b) ( a b -- range ) twiddle (a, ,b) <range> ; inline

: [0,b] ( b -- range ) 0 swap [a,b] ; inline

: [1,b] ( b -- range ) 1 swap [a,b] ; inline

: [0,b) ( b -- range ) 0 swap [a,b) ; inline

: range-increasing? ( range -- ? )
    step>> 0 > ;

: range-decreasing? ( range -- ? )
    step>> 0 < ;

: first-or-peek ( seq head? -- elt )
    [ first ] [ peek ] if ;

: range-min ( range -- min )
    dup range-increasing? first-or-peek ;

: range-max ( range -- max )
    dup range-decreasing? first-or-peek ;

: clamp-to-range ( n range -- n )
    [ range-min max ] [ range-max min ] bi ;

: sequence-index-range  ( seq -- range )
    length [0,b) ;
