! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences sequences.deep kernel
compiler.tree compiler.tree.def-use ;
IN: compiler.tree.def-use.simplified

! Simplified def-use follows chains of copies.

! A 'real' usage is a usage of a value that is not a #renaming.
TUPLE: real-usage value node ;

GENERIC: actually-used-by* ( value node -- real-usages )

! Def
GENERIC: actually-defined-by* ( value node -- real-usage )

: actually-defined-by ( value -- real-usage )
    dup defined-by actually-defined-by* ;

M: #renaming actually-defined-by*
    inputs/outputs swap [ index ] dip nth actually-defined-by ;

M: #return-recursive actually-defined-by* real-usage boa ;

M: node actually-defined-by* real-usage boa ;

! Use
: (actually-used-by) ( value -- real-usages )
    dup used-by [ actually-used-by* ] with map ;

M: #renaming actually-used-by*
    inputs/outputs [ indices ] dip nths
    [ (actually-used-by) ] map ;

M: #return-recursive actually-used-by* real-usage boa ;

M: node actually-used-by* real-usage boa ;

: actually-used-by ( value -- real-usages )
    (actually-used-by) flatten ;
