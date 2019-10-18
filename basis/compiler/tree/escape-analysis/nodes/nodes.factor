! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences fry math namespaces
compiler.tree
compiler.tree.def-use
compiler.tree.escape-analysis.allocations ;
IN: compiler.tree.escape-analysis.nodes

GENERIC: escape-analysis* ( node -- )

SYMBOL: next-node

: each-with-next ( ... seq quot: ( ... elt -- ... ) -- ... )
    dupd '[ 1 + _ ?nth next-node set @ ] each-index ; inline

: (escape-analysis) ( nodes -- )
    [
        [ node-defs-values introduce-values ]
        [ escape-analysis* ]
        bi
    ] each-with-next ;
