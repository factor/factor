! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors arrays
stack-checker.inlining
compiler.tree
compiler.tree.propagation.info
compiler.tree.propagation.nodes
compiler.tree.propagation.simple
compiler.tree.propagation.branches ;
IN: compiler.tree.propagation.recursive

! What if we reach a fixed point for the phi but not for the
! #call-label output?

! We need to compute scalar evolution so that sccp doesn't
! evaluate loops

! row polymorphism is causing problems

! infer-branch cloning and subsequent loss of state causing problems

: merge-value-infos ( inputs -- infos )
    [ [ value-info ] map value-infos-union ] map ;
USE: io
: compute-fixed-point ( label infos outputs -- )
    2dup [ length ] bi@ = [ "Wrong length" throw ] unless
    "compute-fixed-point" print USE: prettyprint
    2dup [ value-info ] map 2dup . . [ = ] 2all? [ 3drop ] [
        [ set-value-info ] 2each
        f >>fixed-point drop
    ] if ;

: propagate-recursive-phi ( label #phi -- )
    "propagate-recursive-phi" print
    [ [ phi-in-d>> merge-value-infos ] [ out-d>> ] bi compute-fixed-point ]
    [ [ phi-in-r>> merge-value-infos ] [ out-r>> ] bi compute-fixed-point ] 2bi ;

USING: namespaces math ;
SYMBOL: iter-counter
0 iter-counter set-global
M: #recursive propagate-around ( #recursive -- )
    "#recursive" print
    iter-counter inc
    iter-counter get 10 > [ "Oops" throw ] when
    [ label>> ] keep
    [ node-child first>> propagate-recursive-phi ]
    [ [ t >>fixed-point drop ] [ node-child first>> (propagate) ] bi* ]
    [ swap fixed-point>> [ drop ] [ propagate-around ] if ]
    2tri ; USE: assocs

M: #call-recursive propagate-before ( #call-label -- )
    [ label>> ] [ label>> return>> [ value-info ] map ] [ out-d>> ] tri
    dup [ dup value-infos get at [ drop ] [ object <class-info> swap set-value-info ] if ] each
    2dup min-length [ tail* ] curry bi@
    compute-fixed-point ;

M: #return propagate-before ( #return -- )
    "#return" print
    dup label>> [
        [ label>> ] [ in-d>> [ value-info ] map ] [ in-d>> ] tri
        compute-fixed-point
    ] [ drop ] if ;
