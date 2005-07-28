! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic hashtables kernel namespaces sequences words ;

! Infer possible classes of values in a dataflow IR.

! Variables used by the class inferencer

! Current value --> class mapping
SYMBOL: value-classes

TUPLE: possibility value class ;

! Maps possibilities to possibilities.
SYMBOL: possible-classes

GENERIC: infer-classes* ( node -- )

: value-class ( value -- class )
    value-classes get hash [ object ] unless* ;

: annotate-node ( node -- )
    #! Annotate the node with the currently-inferred set of
    #! value classes.
    dup node-values [ value-class ] map>hash
    swap set-node-classes ;

M: node infer-classes* ( node -- ) drop ;

: assume-classes ( classes values -- )
    [ value-classes get set-hash ] 2each ;

: intersect-classes ( classes values -- )
    [ [ value-class class-and ] 2map ] keep assume-classes ;

M: #call infer-classes* ( node -- )
    dup node-param "infer-effect" word-prop 2unseq
    pick node-out-d assume-classes
    swap node-in-d intersect-classes ;

M: #push infer-classes* ( node -- )
    node-out-d [
        dup safe-literal? [
            [ literal-value class ] keep
            value-classes get set-hash
        ] [
            drop
        ] ifte
    ] each ;

: (infer-classes) ( node -- )
    dup infer-classes*
    dup annotate-node
    dup node-children [ (infer-classes) ] each
    node-successor [ (infer-classes) ] when* ;

: infer-classes ( node -- )
    [
        <namespace> value-classes set
        <namespace> possible-classes set
        (infer-classes)
    ] with-scope ;
