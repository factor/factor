! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry kernel sequences assocs accessors namespaces
math.intervals arrays classes.algebra locals
compiler.tree
compiler.tree.def-use
compiler.tree.propagation.info
compiler.tree.propagation.nodes
compiler.tree.propagation.simple
compiler.tree.propagation.constraints ;
IN: compiler.tree.propagation.branches

! For conditionals, an assoc of child node # --> constraint
GENERIC: child-constraints ( node -- seq )

M: #if child-constraints
    in-d>> first [ =t ] [ =f ] bi 2array ;

M: #dispatch child-constraints
    children>> length f <repetition> ;

GENERIC: live-children ( #branch -- children )

M: #if live-children
    [ children>> ] [ in-d>> first value-info possible-boolean-values ] bi
    [ t swap memq? [ first ] [ drop f ] if ]
    [ f swap memq? [ second ] [ drop f ] if ]
    2bi 2array ;

M: #dispatch live-children
    [ children>> ] [ in-d>> first value-info interval>> ] bi
    '[ , interval-contains? [ drop f ] unless ] map-index ;

SYMBOL: infer-children-data

: infer-children ( node -- )
    [ live-children ] [ child-constraints ] bi [
        [
            over [
                value-infos [ clone ] change
                constraints [ clone ] change
                assume
                (propagate)
            ] [
                2drop
                value-infos off
                constraints off
            ] if
        ] H{ } make-assoc
    ] 2map infer-children-data set ;

: (merge-value-infos) ( inputs results -- infos )
    '[ , [ [ value-info ] bind ] 2map value-infos-union ] map ;

: merge-value-infos ( results inputs outputs -- )
    [ swap (merge-value-infos) ] dip set-value-infos ;

M: #phi propagate-before ( #phi -- )
    infer-children-data get swap
    [ [ phi-in-d>> ] [ out-d>> ] bi merge-value-infos ]
    [ [ phi-in-r>> ] [ out-r>> ] bi merge-value-infos ]
    2bi ;

:: branch-phi-constraints ( x #phi -- )
    #phi [ out-d>> ] [ phi-in-d>> ] bi [
        first2 2dup and [ USE: prettyprint
            [ [ =t x =t /\ ] [ =t x =f /\ ] bi* \/ swap t--> dup  . assume ]
            [ [ =f x =t /\ ] [ =f x =f /\ ] bi* \/ swap f--> dup  . assume ]
            3bi
        ] [ 3drop ] if
    ] 2each ;

! : merge-children
!     [ successor>> propagate-branch-phi ]
!     [ [ in-d>> first ] [ successor>> ] bi 2drop ] ! branch-phi-constraints ]
!     bi ;

M: #branch propagate-around
    [ infer-children ] [ annotate-node ] bi ;
