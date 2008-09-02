! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences words namespaces
classes.builtin
compiler.tree
compiler.tree.builder
compiler.tree.normalization
compiler.tree.propagation
compiler.tree.cleanup
compiler.tree.def-use
compiler.tree.dead-code
compiler.tree.combinators ;
IN: compiler.tree.finalization

GENERIC: finalize* ( node -- nodes )

M: #copy finalize* drop f ;

M: #shuffle finalize*
    dup shuffle-effect
    [ in>> ] [ out>> ] bi sequence=
    [ drop f ] when ;

: builtin-predicate? ( word -- ? )
    "predicating" word-prop builtin-class? ;

: splice-quot ( quot -- nodes )
    [
        build-tree
        normalize
        propagate
        cleanup
        compute-def-use
        remove-dead-code
        but-last
    ] with-scope ;

M: #call finalize*
    dup word>> builtin-predicate? [
        word>> def>> splice-quot
    ] when ;

M: node finalize* ;

: finalize ( nodes -- nodes' ) [ finalize* ] map-nodes ;
