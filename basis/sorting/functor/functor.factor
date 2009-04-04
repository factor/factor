! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: functors kernel math.order sequences sorting ;
IN: sorting.functor

FUNCTOR: define-sorting ( NAME QUOT -- )

NAME<=> DEFINES ${NAME}<=>
NAME>=< DEFINES ${NAME}>=<
NAME-compare DEFINES ${NAME}-compare
NAME-sort DEFINES ${NAME}-sort
NAME-sort-keys DEFINES ${NAME}-sort-keys
NAME-sort-values DEFINES ${NAME}-sort-values

WHERE

: NAME<=> ( obj1 obj2 -- <=> ) QUOT bi@ <=> ;
: NAME>=< ( obj1 obj2 -- >=< ) NAME<=> invert-comparison ;
: NAME-compare ( obj1 obj2 quot -- <=> ) bi@ NAME<=> ; inline
: NAME-sort ( seq -- sortedseq ) [ NAME<=> ] sort ;
: NAME-sort-keys ( seq -- sortedseq ) [ [ first ] NAME-compare ] sort ;
: NAME-sort-values ( seq -- sortedseq ) [ [ second ] NAME-compare ] sort ;

;FUNCTOR
