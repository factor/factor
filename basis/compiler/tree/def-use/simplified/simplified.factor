! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel fry vectors
compiler.tree compiler.tree.def-use ;
IN: compiler.tree.def-use.simplified

! Simplified def-use follows chains of copies.

! A 'real' usage is a usage of a value that is not a #renaming.
TUPLE: real-usage value node ;

! Def
GENERIC: actually-defined-by* ( value node -- real-usage )

: actually-defined-by ( value -- real-usage )
    dup defined-by actually-defined-by* ;

M: #renaming actually-defined-by*
    inputs/outputs swap [ index ] dip nth actually-defined-by ;

M: #return-recursive actually-defined-by* real-usage boa ;

M: node actually-defined-by* real-usage boa ;

! Use
GENERIC# actually-used-by* 1 ( value node accum -- )

: (actually-used-by) ( value accum -- )
    [ [ used-by ] keep ] dip '[ _ swap _ actually-used-by* ] each ;

M: #renaming actually-used-by*
    [ inputs/outputs [ indices ] dip nths ] dip
    '[ _ (actually-used-by) ] each ;

M: #return-recursive actually-used-by* [ real-usage boa ] dip push ;

M: node actually-used-by* [ real-usage boa ] dip push ;

: actually-used-by ( value -- real-usages )
    10 <vector> [ (actually-used-by) ] keep ;
