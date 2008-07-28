! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces disjoint-sets sequences assocs math
kernel accessors fry
compiler.tree compiler.tree.def-use compiler.tree.combinators ;
IN: compiler.tree.copy-equiv

! Disjoint set of copy equivalence
SYMBOL: copies

: is-copy-of ( val copy -- ) copies get equate ;

: are-copies-of ( vals copies -- ) [ is-copy-of ] 2each ;

: resolve-copy ( copy -- val ) copies get representative ;

: introduce-value ( val -- ) copies get add-atom ;

GENERIC: compute-copy-equiv* ( node -- )

M: #shuffle compute-copy-equiv*
    [ out-d>> dup ] [ mapping>> ] bi
    '[ , at ] map swap are-copies-of ;

M: #>r compute-copy-equiv*
    [ in-d>> ] [ out-r>> ] bi are-copies-of ;

M: #r> compute-copy-equiv*
    [ in-r>> ] [ out-d>> ] bi are-copies-of ;

M: #copy compute-copy-equiv*
    [ in-d>> ] [ out-d>> ] bi are-copies-of ;

M: #return-recursive compute-copy-equiv*
    [ in-d>> ] [ out-d>> ] bi are-copies-of ;

: unchanged-underneath ( #call-recursive -- n )
    [ out-d>> length ] [ label>> return>> in-d>> length ] bi - ;

M: #call-recursive compute-copy-equiv*
    [ in-d>> ] [ out-d>> ] [ unchanged-underneath ] tri
    '[ , head ] bi@ are-copies-of ;

M: node compute-copy-equiv* drop ;

: compute-copy-equiv ( node -- node )
    <disjoint-set> copies set
    dup [
        [ node-defs-values [ introduce-value ] each ]
        [ compute-copy-equiv* ]
        bi
    ] each-node ;
