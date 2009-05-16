! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays namespaces sequences kernel generic assocs
classes vectors accessors combinators sets
stack-checker.state
stack-checker.branches
compiler.tree
compiler.tree.combinators ;
IN: compiler.tree.def-use

SYMBOL: def-use

TUPLE: definition value node uses ;

: <definition> ( node value -- definition )
    definition new
        swap >>value
        swap >>node
        V{ } clone >>uses ;

ERROR: no-def-error value ;

: def-of ( value -- definition )
    dup def-use get at* [ nip ] [ no-def-error ] if ;

ERROR: multiple-defs-error ;

: def-value ( node value -- )
    def-use get 2dup key? [
        multiple-defs-error
    ] [
        [ [ <definition> ] keep ] dip set-at
    ] if ;

: used-by ( value -- nodes ) def-of uses>> ;

: use-value ( node value -- ) used-by push ;

: defined-by ( value -- node ) def-of node>> ;

GENERIC: node-uses-values ( node -- values )

M: #introduce node-uses-values drop f ;
M: #push node-uses-values drop f ;
M: #phi node-uses-values phi-in-d>> concat remove-bottom prune ;
M: #declare node-uses-values declaration>> keys ;
M: #terminate node-uses-values [ in-d>> ] [ in-r>> ] bi append ;
M: #shuffle node-uses-values [ in-d>> ] [ in-r>> ] bi append ;
M: #alien-callback node-uses-values drop f ;
M: node node-uses-values in-d>> ;

GENERIC: node-defs-values ( node -- values )

M: #shuffle node-defs-values [ out-d>> ] [ out-r>> ] bi append ;
M: #branch node-defs-values drop f ;
M: #declare node-defs-values drop f ;
M: #return node-defs-values drop f ;
M: #recursive node-defs-values drop f ;
M: #terminate node-defs-values drop f ;
M: #alien-callback node-defs-values drop f ;
M: node node-defs-values out-d>> ;

: node-def-use ( node -- )
    [ dup node-uses-values [ use-value ] with each ]
    [ dup node-defs-values [ def-value ] with each ] bi ;

: compute-def-use ( node -- node )
    H{ } clone def-use set
    dup [ node-def-use ] each-node ;
