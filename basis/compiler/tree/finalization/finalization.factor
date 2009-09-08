! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences words memoize combinators
classes classes.builtin classes.tuple classes.singleton
math.partial-dispatch fry assocs combinators.short-circuit
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
    dup {
        [ [ in-d>> length ] [ out-d>> length ] bi = ]
        [ [ in-r>> length ] [ out-r>> length ] bi = ]
        [ [ in-d>> ] [ out-d>> ] [ mapping>> ] tri '[ _ at = ] 2all? ]
        [ [ in-r>> ] [ out-r>> ] [ mapping>> ] tri '[ _ at = ] 2all? ]
    } 1&& [ drop f ] when ;

MEMO: cached-expansion ( word -- nodes )
    def>> splice-final ;

GENERIC: finalize-word ( #call word -- nodes )

M: predicate finalize-word
    "predicating" word-prop {
        { [ dup builtin-class? ] [ drop word>> cached-expansion ] }
        { [ dup tuple-class? ] [ drop word>> def>> splice-final ] }
        { [ dup singleton-class? ] [ drop word>> def>> splice-final ] }
        [ drop ]
    } cond ;

M: math-partial finalize-word
    dup primitive? [ drop ] [ nip cached-expansion ] if ;

M: word finalize-word drop ;

M: #call finalize*
    dup word>> finalize-word ;

M: node finalize* ;
