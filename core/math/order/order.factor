! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math ;
IN: math.order

SYMBOL: +lt+
SYMBOL: +eq+
SYMBOL: +gt+

GENERIC: <=> ( obj1 obj2 -- n )

: (<=>) - dup 0 < [ drop +lt+ ] [ zero? +eq+ +gt+ ? ] if ;

: invert-comparison ( symbol -- new-symbol )
    dup +lt+ eq? [ drop +gt+ ] [ +eq+ eq? +eq+ +lt+ ? ] if ;

M: real <=> (<=>) ;
M: integer <=> (<=>) ;

GENERIC: before? ( obj1 obj2 -- ? )
GENERIC: after? ( obj1 obj2 -- ? )
GENERIC: before=? ( obj1 obj2 -- ? )
GENERIC: after=? ( obj1 obj2 -- ? )

M: object before? ( obj1 obj2 -- ? ) <=> +lt+ eq? ;
M: object after? ( obj1 obj2 -- ? ) <=> +gt+ eq? ;
M: object before=? ( obj1 obj2 -- ? ) <=> +gt+ eq? not ;
M: object after=? ( obj1 obj2 -- ? ) <=> +lt+ eq? not ;

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
