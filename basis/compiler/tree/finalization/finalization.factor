! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences words memoize combinators
classes classes.builtin classes.tuple math.partial-dispatch
fry assocs
compiler.tree
compiler.tree.combinators
compiler.tree.propagation.info
compiler.tree.late-optimizations ;
IN: compiler.tree.finalization

! This is a late-stage optimization.
! See the comment in compiler.tree.late-optimizations.

! This pass runs after propagation, so that it can expand
! type predicates; these cannot be expanded before
! propagation since we need to see 'fixnum?' instead of
! 'tag 0 eq?' and so on, for semantic reasoning.

! We also delete empty stack shuffles and copies to facilitate
! tail call optimization in the code generator.

GENERIC: finalize* ( node -- nodes )

: finalize ( nodes -- nodes' ) [ finalize* ] map-nodes ;

: splice-final ( quot -- nodes ) splice-quot finalize ;

M: #copy finalize* drop f ;

M: #shuffle finalize*
    dup
    [ [ in-d>> ] [ out-d>> ] [ mapping>> ] tri '[ _ at ] map sequence= ]
    [ [ in-r>> ] [ out-r>> ] [ mapping>> ] tri '[ _ at ] map sequence= ]
    bi and [ drop f ] when ;

MEMO: cached-expansion ( word -- nodes )
    def>> splice-final ;

GENERIC: finalize-word ( #call word -- nodes )

M: predicate finalize-word
    "predicating" word-prop {
        { [ dup builtin-class? ] [ drop word>> cached-expansion ] }
        { [ dup tuple-class? ] [ drop word>> def>> splice-final ] }
        [ drop ]
    } cond ;

M: word finalize-word drop ;

M: #call finalize*
    dup word>> finalize-word ;

M: node finalize* ;
