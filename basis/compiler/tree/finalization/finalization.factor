! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences words memoize classes.builtin
compiler.tree
compiler.tree.combinators
compiler.tree.propagation.info
compiler.tree.late-optimizations ;
IN: compiler.tree.finalization

! This is a late-stage optimization.
! See the comment in compiler.tree.late-optimizations.

! This pass runs after propagation, so that it can expand
! built-in type predicates; these cannot
! be expanded before propagation since we need to see 'fixnum?'
! instead of 'tag 0 eq?' and so on, for semantic reasoning.
! We also delete empty stack shuffles and copies to facilitate
! tail call optimization in the code generator.

GENERIC: finalize* ( node -- nodes )

: finalize ( nodes -- nodes' ) [ finalize* ] map-nodes ;

: splice-final ( quot -- nodes ) splice-quot finalize ;

M: #copy finalize* drop f ;

M: #shuffle finalize*
    dup shuffle-effect
    [ in>> ] [ out>> ] bi sequence=
    [ drop f ] when ;

: builtin-predicate? ( #call -- ? )
    word>> "predicating" word-prop builtin-class? ;

MEMO: builtin-predicate-expansion ( word -- nodes )
    def>> splice-final ;

: expand-builtin-predicate ( #call -- nodes )
    word>> builtin-predicate-expansion ;

M: #call finalize*
    dup builtin-predicate? [ expand-builtin-predicate ] when ;

M: node finalize* ;
