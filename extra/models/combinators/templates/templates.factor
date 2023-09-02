USING: fry functors generalizations kernel macros sequences
sequences.generalizations ;
IN: models.combinators.templates
FROM: models.combinators => <collection> #1 ;
<FUNCTOR: fmaps ( W -- )
W        IS ${W}
w-n      DEFINES ${W}-n
w-2      DEFINES 2${W}
w-3      DEFINES 3${W}
w-4      DEFINES 4${W}
w-n*     DEFINES ${W}-n*
w-2*     DEFINES 2${W}*
w-3*     DEFINES 3${W}*
w-4*     DEFINES 4${W}*
WHERE
MACRO: w-n ( int -- quot )
    dup '[ [ _ narray <collection> ] dip [ _ firstn ] prepend W ] ;
: w-2 ( a b quot -- mapped ) 2 w-n ; inline
: w-3 ( a b c quot -- mapped ) 3 w-n ; inline
: w-4 ( a b c d quot -- mapped ) 4 w-n ; inline
MACRO: w-n* ( int -- quot )
    dup '[ [ _ narray <collection> #1 ] dip [ _ firstn ] prepend W ] ;
: w-2* ( a b quot -- mapped ) 2 w-n* ; inline
: w-3* ( a b c quot -- mapped ) 3 w-n* ; inline
: w-4* ( a b c d quot -- mapped ) 4 w-n* ; inline
;FUNCTOR>
