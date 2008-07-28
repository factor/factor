! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors slots.private kernel namespaces disjoint-sets
math sequences assocs classes.tuple.private combinators fry sets
compiler.tree compiler.tree.combinators compiler.tree.copy-equiv
compiler.tree.dataflow-analysis
compiler.tree.dataflow-analysis.backward ;
IN: compiler.tree.untupling

SYMBOL: escaping-values

: mark-escaping-values ( node -- )
    in-d>> escaping-values get '[ resolve-copy , conjoin ] each ;

SYMBOL: untupling-candidates

: untupling-candidate ( #call class -- )
    #! 1- for delegate
    size>> 1- swap out-d>> first resolve-copy
    untupling-candidates get set-at ;

GENERIC: compute-untupling* ( node -- )

M: #call compute-untupling*
    dup word>> {
        { \ <tuple-boa> [ dup in-d>> peek untupling-candidate ] }
        { \ curry [ \ curry tuple-layout untupling-candidate ] }
        { \ compose [ \ compose tuple-layout untupling-candidate ] }
        { \ slot [ drop ] }
        [ drop mark-escaping-values ]
    } case ;

M: #return compute-untupling* mark-escaping-values ;

M: node compute-untupling* drop ;

GENERIC: check-consistency* ( node -- )

: check-value-consistency ( out-value in-values -- )
    swap escaping-values get key? [
        escaping-values get '[ , conjoin ] each
    ] [
        untupling-candidates get 2dup '[ , at ] map all-equal?
        [ 2drop ] [ '[ , delete-at ] each ] if
    ] if ;

M: #phi check-consistency*
    [ [ out-d>> ] [ phi-in-d>> ] bi [ check-value-consistency ] 2each ]
    [ [ out-r>> ] [ phi-in-r>> ] bi [ check-value-consistency ] 2each ]
    bi ;

M: node check-consistency* drop ;

: compute-untupling ( node -- assoc )
    H{ } clone escaping-values set
    H{ } clone untupling-candidates set
    [ [ compute-untupling* ] each-node ]
    [ [ check-consistency* ] each-node ] bi
    untupling-candidates get escaping-values get assoc-diff ;
