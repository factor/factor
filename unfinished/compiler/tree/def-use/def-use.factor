! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs sequences kernel generic assocs classes
vectors accessors combinators sets stack-checker.state
compiler.tree compiler.tree.combinators ;
IN: compiler.tree.def-use

SYMBOL: def-use

TUPLE: definition value node uses ;

: <definition> ( value -- definition )
    definition new
        swap >>value
        V{ } clone >>uses ;

: def-of ( value -- definition )
    def-use get [ <definition> ] cache ;

: def-value ( node value -- )
    def-of [ [ "Multiple defs" throw ] when ] change-node drop ;

: used-by ( value -- nodes ) def-of uses>> ;

: use-value ( node value -- ) used-by push ;

: defined-by ( value -- node ) def-use get at node>> ;

GENERIC: node-uses-values ( node -- values )

M: #declare node-uses-values declaration>> keys ;

M: #phi node-uses-values
    [ phi-in-d>> concat ] [ phi-in-r>> concat ] bi
    append sift prune ;

M: #r> node-uses-values in-r>> ;

M: node node-uses-values in-d>> ;

GENERIC: node-defs-values ( node -- values )

M: #introduce node-defs-values values>> ;

M: #>r node-defs-values out-r>> ;

M: #phi node-defs-values [ out-d>> ] [ out-r>> ] bi append ;

M: node node-defs-values out-d>> ;

: node-def-use ( node -- )
    [ dup node-uses-values [ use-value ] with each ]
    [ dup node-defs-values [ def-value ] with each ] bi ;

: check-def-use ( -- )
    def-use get [
        nip
        [ node>> [ "No def" throw ] unless ]
        [ uses>> all-unique? [ "Uses not all unique" throw ] unless ]
        bi
    ] assoc-each ;

: compute-def-use ( node -- node )
    H{ } clone def-use set
    dup [ node-def-use ] each-node
    check-def-use ;
