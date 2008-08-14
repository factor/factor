! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays namespaces assocs sequences kernel generic assocs
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

: def-of ( value -- definition )
    def-use get at* [ "No def" throw ] unless ;

: def-value ( node value -- )
    def-use get 2dup key? [
        "Multiple defs" throw
    ] [
        [ [ <definition> ] keep ] dip set-at
    ] if ;

: used-by ( value -- nodes ) def-of uses>> ;

: use-value ( node value -- ) used-by push ;

: defined-by ( value -- node ) def-of node>> ;

GENERIC: node-uses-values ( node -- values )

M: #introduce node-uses-values drop f ;
M: #push node-uses-values drop f ;
M: #r> node-uses-values in-r>> ;
M: #phi node-uses-values
    [ phi-in-d>> ] [ phi-in-r>> ] bi
    append concat remove-bottom prune ;
M: #declare node-uses-values declaration>> keys ;
M: node node-uses-values in-d>> ;

GENERIC: node-defs-values ( node -- values )

M: #>r node-defs-values out-r>> ;
M: #branch node-defs-values drop f ;
M: #phi node-defs-values [ out-d>> ] [ out-r>> ] bi append ;
M: #declare node-defs-values drop f ;
M: #return node-defs-values drop f ;
M: #recursive node-defs-values drop f ;
M: #terminate node-defs-values drop f ;
M: node node-defs-values out-d>> ;

: node-def-use ( node -- )
    [ dup node-uses-values [ use-value ] with each ]
    [ dup node-defs-values [ def-value ] with each ] bi ;

: compute-def-use ( node -- node )
    H{ } clone def-use set
    dup [ node-def-use ] each-node ;
