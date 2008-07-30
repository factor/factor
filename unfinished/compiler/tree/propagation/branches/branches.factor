! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry kernel sequences assocs accessors namespaces
math.intervals arrays classes.algebra combinators
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

: copy-value-info ( -- )
    value-infos [ clone ] change
    constraints [ clone ] change ;

: infer-children ( node -- )
    [ live-children ] [ child-constraints ] bi [
        [
            over [
                copy-value-info
                assume
                (propagate)
            ] [
                2drop
                value-infos off
                constraints off
            ] if
        ] H{ } make-assoc
    ] 2map infer-children-data set ;

: compute-phi-input-infos ( phi-in -- phi-info )
    infer-children-data get
    '[ , [ [ value-info ] bind ] 2map ] map ;

: annotate-phi-node ( #phi -- )
    dup phi-in-d>> compute-phi-input-infos >>phi-info-d
    dup phi-in-r>> compute-phi-input-infos >>phi-info-r
    dup [ out-d>> ] [ out-r>> ] bi append extract-value-info >>info
    drop ;

: merge-value-infos ( infos outputs -- )
    [ [ value-infos-union ] map ] dip set-value-infos ;

SYMBOL: condition-value

M: #phi propagate-before ( #phi -- )
    [ annotate-phi-node ]
    [ [ phi-info-d>> ] [ out-d>> ] bi merge-value-infos ]
    [ [ phi-info-r>> ] [ out-r>> ] bi merge-value-infos ]
    tri ;

: branch-phi-constraints ( output values booleans -- )
     {
        {
            { { t } { f } }
            [
                drop condition-value get
                [ [ =t ] [ =t ] bi* <--> ]
                [ [ =f ] [ =f ] bi* <--> ] 2bi /\ assume
            ]
        }
        {
            { { f } { t } }
            [
                drop condition-value get
                [ [ =t ] [ =f ] bi* <--> ]
                [ [ =f ] [ =t ] bi* <--> ] 2bi /\ assume
            ]
        }
        {
            { { t f } { f } }
            [ first =t condition-value get =t /\ swap t--> assume ]
        }
        {
            { { f } { t f } }
            [ second =t condition-value get =f /\ swap t--> assume ]
        }
        [ 3drop ]
    } case ;

M: #phi propagate-after ( #phi -- )
    condition-value get [
        [ out-d>> ] [ phi-in-d>> ] [ phi-info-d>> ] tri
        3array flip [
            first3 [ possible-boolean-values ] map
            branch-phi-constraints
        ] each
    ] [ drop ] if ;

M: #phi propagate-around ( #phi -- )
    [ propagate-before ] [ propagate-after ] bi ;

M: #branch propagate-around
    [ infer-children ] [ annotate-node ] bi ;

M: #if propagate-around
    [ in-d>> first condition-value set ] [ call-next-method ] bi ;

M: #dispatch propagate-around
    condition-value off call-next-method ;
