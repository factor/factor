! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.tree.def-use
compiler.tree.escape-analysis.allocations fry kernel math
namespaces sequences ;
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
