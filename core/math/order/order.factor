! Copyright (C) 2008, 2010 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private math ;
IN: math.order

SYMBOL: +lt+
SYMBOL: +eq+
SYMBOL: +gt+

: invert-comparison ( <=> -- >=< )
    ! Can't use case, index or nth here
    dup +lt+ eq? [ drop +gt+ ] [ +eq+ eq? +eq+ +lt+ ? ] if ;

GENERIC: <=> ( obj1 obj2 -- <=> )

: >=< ( obj1 obj2 -- >=< ) <=> invert-comparison ; inline

<PRIVATE

! Defining a math generic for comparison forces a single math
! promotion, and speeds up comparisons on numbers.
: (real<=>) ( x y -- <=> )
    2dup < [ 2drop +lt+ ] [ number= +eq+ +gt+ ? ] if ; inline

MATH: real<=> ( x y -- <=> )
M: fixnum real<=> { fixnum fixnum } declare (real<=>) ; inline
M: bignum real<=> { bignum bignum } declare (real<=>) ; inline
M: float real<=> { float float } declare (real<=>) ; inline
M: real real<=> (real<=>) ; inline

PRIVATE>

M: real <=> real<=> ; inline

GENERIC: before? ( obj1 obj2 -- ? )
GENERIC: after? ( obj1 obj2 -- ? )
GENERIC: before=? ( obj1 obj2 -- ? )
GENERIC: after=? ( obj1 obj2 -- ? )

M: object before? <=> +lt+ eq? ; inline
M: object after? <=> +gt+ eq? ; inline
M: object before=? <=> +gt+ eq? not ; inline
M: object after=? <=> +lt+ eq? not ; inline

M: real before? < ; inline
M: real after? > ; inline
M: real before=? <= ; inline
M: real after=? >= ; inline

GENERIC: min ( obj1 obj2 -- obj )
GENERIC: max ( obj1 obj2 -- obj )

M: object min [ before? ] most ; inline
M: object max [ after? ] most ; inline

: clamp ( x min max -- y ) [ max ] dip min ; inline

: between? ( x min max -- ? )
    pick after=? [ after=? ] [ 2drop f ] if ; inline

: [-] ( x y -- z ) - 0 max ; inline

: compare ( obj1 obj2 quot -- <=> ) bi@ <=> ; inline
