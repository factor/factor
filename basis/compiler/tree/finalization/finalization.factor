! Copyright (C) 2008, 2009 Slava Pestov.
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

GENERIC: finalize* ( node -- nodes )

: finalize ( nodes -- nodes' ) [ finalize* ] map-nodes ;

: splice-final ( quot -- nodes ) splice-quot finalize ;

MEMO: cached-expansion ( word -- nodes )
    def>> splice-final ;

GENERIC: finalize-word ( #call word -- nodes )

M: predicate finalize-word
    "predicating" word-prop {
        { [ dup builtin-class? ] [ drop word>> cached-expansion ] }
        { [ dup tuple-class? ] [ drop word>> def>> splice-final ] }
        [ drop ]
    } cond ;

M: math-partial finalize-word
    dup primitive? [ drop ] [ nip cached-expansion ] if ;

M: word finalize-word drop ;

M: #call finalize*
    dup word>> finalize-word ;

M: node finalize* ;
