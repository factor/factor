! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math ;
IN: math.order

GENERIC: <=> ( obj1 obj2 -- n )

M: real <=> - ;
M: integer <=> - ;

GENERIC: before? ( obj1 obj2 -- ? )
GENERIC: after? ( obj1 obj2 -- ? )
GENERIC: before=? ( obj1 obj2 -- ? )
GENERIC: after=? ( obj1 obj2 -- ? )

M: object before? ( obj1 obj2 -- ? ) <=> 0 < ;
M: object after? ( obj1 obj2 -- ? ) <=> 0 > ;
M: object before=? ( obj1 obj2 -- ? ) <=> 0 <= ;
M: object after=? ( obj1 obj2 -- ? ) <=> 0 >= ;

M: real before? ( obj1 obj2 -- ? ) < ;
M: real after? ( obj1 obj2 -- ? ) > ;
M: real before=? ( obj1 obj2 -- ? ) <= ;
M: real after=? ( obj1 obj2 -- ? ) >= ;

: min ( x y -- z ) [ before? ] most ; inline 
: max ( x y -- z ) [ after? ] most ; inline

: between? ( x y z -- ? )
    pick after=? [ after=? ] [ 2drop f ] if ; inline

: [-] ( x y -- z ) - 0 max ; inline

: compare ( obj1 obj2 quot -- n ) bi@ <=> ; inline
