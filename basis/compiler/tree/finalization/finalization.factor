! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes classes.builtin
classes.singleton classes.tuple combinators
combinators.short-circuit compiler.tree
compiler.tree.combinators compiler.tree.late-optimizations fry
kernel math.partial-dispatch memoize sequences
stack-checker.dependencies words ;
IN: compiler.tree.finalization

GENERIC: finalize* ( node -- nodes )

: finalize ( nodes -- nodes' ) [ finalize* ] map-nodes ;

: splice-final ( quot -- nodes ) splice-quot finalize ;

: splice-predicate ( word -- nodes )
    [ +definition+ depends-on ] [ def>> splice-final ] bi ;

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
        { [ dup tuple-class? ] [ drop word>> splice-predicate ] }
        { [ dup singleton-class? ] [ drop word>> splice-predicate ] }
        [ drop ]
    } cond ;

M: math-partial finalize-word
    dup primitive? [ drop ] [ nip cached-expansion ] if ;

M: word finalize-word drop ;

M: #call finalize*
    dup word>> finalize-word ;

M: node finalize* ;
