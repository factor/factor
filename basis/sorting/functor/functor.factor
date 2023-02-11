! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: functors math.order ;
IN: sorting.functor

<FUNCTOR: define-sorting ( NAME QUOT -- )

NAME<=> DEFINES ${NAME}<=>
NAME>=< DEFINES ${NAME}>=<

WHERE

: NAME<=> ( obj1 obj2 -- <=> ) QUOT compare ;
: NAME>=< ( obj1 obj2 -- >=< ) NAME<=> invert-comparison ;

;FUNCTOR>
