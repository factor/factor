! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic hashtables kernel namespaces sequences vectors
words ;

! Infer possible classes of values in a dataflow IR.

! Variables used by the class inferencer

! Current value --> class mapping
SYMBOL: value-classes

! Current value --> literal mapping
SYMBOL: value-literals

GENERIC: apply-tie ( tie -- )

M: f apply-tie ( f -- ) drop ;

TUPLE: class-tie value class ;

: set-value-class ( class value -- )
    2dup swap <class-tie> ties get hash [ apply-tie ] when*
    value-classes get set-hash ;

M: class-tie apply-tie ( tie -- )
    dup class-tie-class swap class-tie-value
    set-value-class ;

TUPLE: literal-tie value literal ;

: set-value-literal ( literal value -- )
    over class over set-value-class
    2dup swap <literal-tie> ties get hash [ apply-tie ] when*
    value-literals get set-hash ;

M: literal-tie apply-tie ( tie -- )
    dup literal-tie-literal swap literal-tie-value
    set-value-literal ;

! Maps ties to ties
SYMBOL: ties

GENERIC: infer-classes* ( node -- )

M: node infer-classes* ( node -- ) drop ;

! For conditionals, a map of child node # --> possibility
GENERIC: child-ties ( node -- seq )

M: node child-ties ( node -- seq )
    node-children length f <repeated> ;

: value-class ( value -- class )
    value-classes get hash [ object ] unless* ;

: value-literal ( value -- class )
    value-literals get hash ;

: annotate-node ( node -- )
    #! Annotate the node with the currently-inferred set of
    #! value classes.
    dup node-values ( 2dup )
    [ value-class ] map>hash swap set-node-classes
    ( [ value-literal ] map>hash swap set-node-literals ) ;

: assume-classes ( classes values -- )
    [ set-value-class ] 2each ;

: assume-literals ( literals values -- )
    [ set-value-literal ] 2each ;

: intersect-classes ( classes values -- )
    [ [ value-class class-and ] 2map ] keep assume-classes ;

: create-ties ( #call -- )
    #! If the node is calling a class test predicate, create a
    #! tie.
    dup node-param "predicating" word-prop dup [
        >r dup node-in-d first r> <class-tie>
        swap node-out-d first general-t <class-tie>
        ties get set-hash
    ] [
        2drop
    ] ifte ;

M: #call infer-classes* ( node -- )
    dup create-ties
    dup node-param "infer-effect" word-prop 2unseq
    pick node-out-d intersect-classes
    swap node-in-d intersect-classes ;

M: #push infer-classes* ( node -- )
    node-out-d [ safe-literal? ] subset
    dup [ literal-value ] map
    swap assume-literals ;

M: #ifte child-ties ( node -- seq )
    node-in-d first dup general-t <class-tie>
    swap f <literal-tie> 2vector ;

M: #dispatch child-ties ( node -- seq )
    dup node-in-d first
    swap node-children length [ <literal-tie> ] map-with ;

DEFER: (infer-classes)

: infer-children ( node -- )
    dup node-children swap child-ties [
        [
            value-classes [ clone ] change
            ties [ clone ] change
            apply-tie
            (infer-classes)
        ] with-scope
    ] 2each ;

: (infer-classes) ( node -- )
    dup infer-classes*
    dup annotate-node
    dup infer-children
    node-successor [ (infer-classes) ] when* ;

: infer-classes ( node -- )
    [
        <namespace> value-classes set
        <namespace> value-literals set
        <namespace> ties set
        (infer-classes)
    ] with-scope ;
