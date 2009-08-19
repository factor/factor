! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math ;
IN: math.order

SYMBOL: +lt+
SYMBOL: +eq+
SYMBOL: +gt+

: invert-comparison ( <=> -- <=>' )
    #! Can't use case, index or nth here
    dup +lt+ eq? [ drop +gt+ ] [ +eq+ eq? +eq+ +lt+ ? ] if ;

GENERIC: <=> ( obj1 obj2 -- <=> )

: >=< ( obj1 obj2 -- >=< ) <=> invert-comparison ; inline

M: real <=> 2dup < [ 2drop +lt+ ] [ number= +eq+ +gt+ ? ] if ; inline

GENERIC: before? ( obj1 obj2 -- ? )
GENERIC: after? ( obj1 obj2 -- ? )
GENERIC: before=? ( obj1 obj2 -- ? )
GENERIC: after=? ( obj1 obj2 -- ? )

M: object before? ( obj1 obj2 -- ? ) <=> +lt+ eq? ; inline
M: object after? ( obj1 obj2 -- ? ) <=> +gt+ eq? ; inline
M: object before=? ( obj1 obj2 -- ? ) <=> +gt+ eq? not ; inline
M: object after=? ( obj1 obj2 -- ? ) <=> +lt+ eq? not ; inline

M: real before? ( obj1 obj2 -- ? ) < ; inline
M: real after? ( obj1 obj2 -- ? ) > ; inline
M: real before=? ( obj1 obj2 -- ? ) <= ; inline
M: real after=? ( obj1 obj2 -- ? ) >= ; inline

: min ( x y -- z ) [ before? ] most ; inline
: max ( x y -- z ) [ after? ] most ; inline
: clamp ( x min max -- y ) [ max ] dip min ; inline

: between? ( x y z -- ? )
    pick after=? [ after=? ] [ 2drop f ] if ; inline

: [-] ( x y -- z ) - 0 max ; inline

: compare ( obj1 obj2 quot -- <=> ) bi@ <=> ; inline
