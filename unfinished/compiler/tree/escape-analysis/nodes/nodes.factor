! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences
compiler.tree
compiler.tree.def-use
compiler.tree.escape-analysis.allocations ;
IN: compiler.tree.escape-analysis.nodes

GENERIC: escape-analysis* ( node -- )

: (escape-analysis) ( node -- )
    [
        [ node-defs-values introduce-values ]
        [ escape-analysis* ]
        bi
    ] each ;
