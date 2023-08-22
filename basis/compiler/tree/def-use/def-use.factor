! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.tree compiler.tree.combinators
fry kernel namespaces sequences stack-checker.branches ;
QUALIFIED: sets
IN: compiler.tree.def-use

SYMBOL: def-use

TUPLE: definition value node uses ;

: <definition> ( node value -- definition )
    definition new
        swap >>value
        swap >>node
        V{ } clone >>uses ;

ERROR: no-def-error value ;

: (def-of) ( value def-use -- definition )
    ?at [ no-def-error ] unless ; inline

: def-of ( value -- definition )
    def-use get (def-of) ;

ERROR: multiple-defs-error ;

: (def-value) ( node value def-use -- )
    2dup key? [
        multiple-defs-error
    ] [
        [ [ <definition> ] keep ] dip set-at
    ] if ; inline

: def-value ( node value -- )
    def-use get (def-value) ;

: def-values ( node values -- )
    def-use get '[ _ (def-value) ] with each ;

: used-by ( value -- nodes ) def-of uses>> ;

: use-value ( node value -- ) used-by push ;

: use-values ( node values -- )
    def-use get '[ _ (def-of) uses>> push ] with each ;

: defined-by ( value -- node ) def-of node>> ;

GENERIC: node-uses-values ( node -- values )

M: #introduce node-uses-values drop f ;
M: #push node-uses-values drop f ;
M: #phi node-uses-values phi-in-d>> concat remove-bottom sets:members ;
M: #declare node-uses-values drop f ;
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
    [ dup node-uses-values use-values ]
    [ dup node-defs-values def-values ] bi ;

: compute-def-use ( node -- node )
    H{ } clone def-use set
    dup [ node-def-use ] each-node ;
