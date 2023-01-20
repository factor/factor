! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.tree
compiler.tree.combinators compiler.tree.propagation.constraints
compiler.tree.propagation.info compiler.tree.propagation.nodes
compiler.tree.propagation.simple fry kernel locals math
namespaces sequences stack-checker.branches ;
FROM: sets => union ;
IN: compiler.tree.propagation.branches

GENERIC: child-constraints ( node -- seq )

M: #if child-constraints
    in-d>> first [ =t ] [ =f ] bi 2array ;

M: #dispatch child-constraints
    children>> length f <repetition> ;

! There is an important invariant here, either no flags are set
! in live-branches, exactly one is set, or all are set.

GENERIC: live-branches ( #branch -- indices )

M: #if live-branches
    in-d>> first value-info class>> {
        { [ dup null-class? ] [ { f f } ] }
        { [ dup true-class? ] [ { t f } ] }
        { [ dup false-class? ] [ { f t } ] }
        [ { t t } ]
    } cond nip ;

M: #dispatch live-branches
    [ children>> ] [ in-d>> first value-info ] bi {
        { [ dup class>> null-class? ] [ drop length f <array> ] }
        { [ dup literal>> integer? not ] [ drop length t <array> ] }
        { [ 2dup literal>> swap bounds-check? not ] [ drop length t <array> ] }
        [ literal>> swap length f <array> [ [ t ] 2dip set-nth ] keep ]
    } cond ;

: live-children ( #branch -- children )
    [ children>> ] [ live-branches>> ] bi select-children ;

SYMBOL: infer-children-data

: copy-value-info ( -- )
    value-infos [ H{ } clone suffix ] change
    constraints [ H{ } clone suffix ] change ;

: no-value-info ( -- )
    value-infos off
    constraints off ;

DEFER: collect-variables

: infer-children ( node -- )
    [ live-children ] [ child-constraints ] bi [
        [
            over
            [ copy-value-info assume (propagate) ]
            [ 2drop no-value-info ]
            if
            collect-variables
        ] with-scope
    ] 2map infer-children-data set ;

: compute-phi-input-infos ( phi-in -- phi-info )
    infer-children-data get
    [
        '[
            _ [
                dup +bottom+ eq?
                [ drop null-info ] [ value-info ] if
            ] with-variables
        ] map
    ] 2map ;

: annotate-phi-inputs ( #phi -- )
    dup phi-in-d>> compute-phi-input-infos >>phi-info-d drop ;

: merge-value-infos ( infos outputs -- )
    [ [ value-infos-union ] map ] dip set-value-infos ;

SYMBOL: condition-value

: collect-variables ( -- hash )
    {
        condition-value
        constraints
        infer-children-data
        value-infos
    } [ dup get ] H{ } map>assoc ;

M: #phi propagate-before ( #phi -- )
    [ annotate-phi-inputs ]
    [ [ phi-info-d>> flip ] [ out-d>> ] bi merge-value-infos ]
    bi ;

:: update-constraints ( new old -- )
    new [| key value | key old [ value union ] change-at ] assoc-each ;

: include-child-constraints ( i -- )
    infer-children-data get nth constraints of last
    constraints get last update-constraints ;

: branch-phi-constraints ( output values booleans -- )
    {
        {
            { { t } { f } }
            [
                drop condition-value get
                [ [ =t ] [ =t ] bi* <--> ]
                [ [ =f ] [ =f ] bi* <--> ] 2bi 2array
            ]
        }
        {
            { { f } { t } }
            [
                drop condition-value get
                [ [ =t ] [ =f ] bi* <--> ]
                [ [ =f ] [ =t ] bi* <--> ] 2bi 2array
            ]
        }
        {
            { { t f } { f } }
            [
                first =t
                condition-value get =t 2array
                swap t-->
            ]
        }
        {
            { { f } { t f } }
            [
                second =t
                condition-value get =f 2array
                swap t-->
            ]
        }
        {
            { { t f } { t } }
            [
                first =f
                condition-value get =t 2array
                swap f-->
            ]
        }
        {
            { { t } { t f } }
            [
                second =f
                condition-value get =f 2array
                swap f-->
            ]
        }
        {
            { { t f } { } }
            [
                first
                [ [ =t ] bi@ <--> ]
                [ [ =f ] bi@ <--> ] 2bi 2array
                0 include-child-constraints
            ]
        }
        {
            { { } { t f } }
            [
                second
                [ [ =t ] bi@ <--> ]
                [ [ =f ] bi@ <--> ] 2bi 2array
                1 include-child-constraints
            ]
        }
        [ 3drop f ]
    } case assume ;

M: #phi propagate-after ( #phi -- )
    condition-value get [
        [ out-d>> ]
        [ phi-in-d>> flip ]
        [ phi-info-d>> flip ] tri
        [
            [ possible-boolean-values ] map
            branch-phi-constraints
        ] 3each
    ] [ drop ] if ;

M: #branch propagate-around
    dup live-branches >>live-branches
    [ infer-children ] [ annotate-node ] bi ;

M: #if propagate-around
    [ in-d>> first condition-value set ] [ call-next-method ] bi ;

M: #dispatch propagate-around
    condition-value off call-next-method ;
