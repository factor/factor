! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors
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

: (merge-value-infos) ( inputs -- infos )
    [ [ value-info ] map value-infos-union ] map ;

: merge-value-infos ( inputs outputs -- fixed-point? )
    [ (merge-value-infos) ] dip
    [ 2dup value-info = [ 2drop t ] [ set-value-info f ] if ] 2all? ;

: propagate-recursive-phi ( #phi -- fixed-point? )
    [ [ phi-in-d>> ] [ out-d>> ] bi merge-value-infos ]
    [ [ phi-in-r>> ] [ out-r>> ] bi merge-value-infos ]
    bi and ;

M: #recursive propagate-around ( #recursive -- )
    dup
    node-child
    [ first>> (propagate) ] [ propagate-recursive-phi ] bi
    [ drop ] [ propagate-around ] if ;

M: #call-recursive propagate-before ( #call-label -- )
    [ label>> returns>> flip ] [ out-d>> ] bi merge-value-infos drop ;
