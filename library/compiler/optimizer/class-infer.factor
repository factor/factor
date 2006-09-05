! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer
USING: arrays generic hashtables inference kernel
kernel-internals math namespaces sequences words parser ;

! Infer possible classes of values in a dataflow IR.
: node-class# ( node n -- class )
    over node-in-d <reversed> ?nth node-class ;

! Variables used by the class inferencer

! Current value --> class mapping
SYMBOL: value-classes

! Current value --> literal mapping
SYMBOL: value-literals

! Maps ties to ties
SYMBOL: ties

GENERIC: apply-tie ( tie -- )

M: f apply-tie drop ;

TUPLE: class-tie value class ;

: set-value-class* ( class value -- )
    2dup swap <class-tie> ties get hash [ apply-tie ] when*
    value-classes get set-hash ;

M: class-tie apply-tie
    dup class-tie-class swap class-tie-value
    set-value-class* ;

TUPLE: literal-tie value literal ;

: set-value-literal* ( literal value -- )
    over class over set-value-class*
    2dup swap <literal-tie> ties get hash [ apply-tie ] when*
    value-literals get set-hash ;

M: literal-tie apply-tie
    dup literal-tie-literal swap literal-tie-value
    set-value-literal* ;

GENERIC: infer-classes* ( node -- )

M: node infer-classes* drop ;

! For conditionals, a map of child node # --> possibility
GENERIC: child-ties ( node -- seq )

M: node child-ties
    node-children length f <array> ;

: value-class* ( value -- class )
    value-classes get hash [ object ] unless* ;

: value-literal* ( value -- class )
    value-literals get hash ;

: annotate-node ( node -- )
    #! Annotate the node with the currently-inferred set of
    #! value classes.
    dup node-values
    [ dup value-class* ] map>hash swap set-node-classes ;

: intersect-classes ( classes values -- )
    [
        [ value-class* class-and ] keep set-value-class*
    ] 2each ;

: set-tie ( tie tie -- ) ties get set-hash ;

: type/tag-ties ( node n -- )
    over node-out-d first over [ <literal-tie> ] map-with
    >r swap node-in-d first swap [ type>class <class-tie> ] map-with r>
    [ set-tie ] 2each ;

\ type [ num-types type/tag-ties ] "create-ties" set-word-prop

\ tag [ num-tags type/tag-ties ] "create-ties" set-word-prop

\ eq? [
    dup node-in-d second value? [
        dup node-in-d first2 value-literal* <literal-tie>
        over node-out-d first general-t <class-tie>
        set-tie
    ] when drop
] "create-ties" set-word-prop

: create-ties ( #call -- )
    #! If the node is calling a class test predicate, create a
    #! tie.
    dup node-param "create-ties" word-prop dup [
        call
    ] [
        drop dup node-param "predicating" word-prop dup [
            >r dup node-in-d first r> <class-tie>
            swap node-out-d first general-t <class-tie>
            set-tie
        ] [
            2drop
        ] if
    ] if ;

\ <tuple> [
    node-in-d first value-literal 1array
] "output-classes" set-word-prop

{ clone (clone) } [
    [
        node-in-d [ value-class* ] map
    ] "output-classes" set-word-prop
] each

: output-classes ( node -- seq )
    dup node-param "output-classes" word-prop [
        call
    ] [
        node-param "infer-effect" word-prop effect-out
        dup [ word? ] all? [ drop f ] unless
    ] if* ;

M: #call infer-classes*
    dup create-ties dup output-classes
    [ swap node-out-d intersect-classes ] [ drop ] if* ;

M: #push infer-classes*
    node-out-d
    [ [ value-literal ] keep set-value-literal* ] each ;

M: #if child-ties
    node-in-d first dup general-t <class-tie>
    swap f <literal-tie> 2array ;

M: #dispatch child-ties
    dup node-in-d first
    swap node-children length [ <literal-tie> ] map-with ;

M: #declare infer-classes*
    dup node-param swap node-in-d [ set-value-class* ] 2each ;

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

: merge-value-class ( # nodes -- class )
    [ swap node-class# ] map-with
    null [ class-or ] reduce ;

: annotate-merge ( nodes values -- )
    dup length
    [ pick merge-value-class swap set-value-class* ] 2each
    drop ;

: merge-children ( node -- )
    dup node-successor dup #merge? [
        over node-children empty? [
            2drop
        ] [
            node-out-d <reversed>
            >r node-children [ last-node ] map r>
            annotate-merge
        ] if
    ] [
        2drop
    ] if ;

: (infer-classes) ( node -- )
    [
        dup infer-classes*
        dup annotate-node
        dup infer-children
        dup merge-children
        node-successor (infer-classes)
    ] when* ;

: ?<hashtable> [ H{ } clone ] unless* ;

: infer-classes-with ( node classes literals -- )
    [
        ?<hashtable> value-literals set
        ?<hashtable> value-classes set
        H{ } clone ties set
        (infer-classes)
    ] with-scope ;

: infer-classes ( node -- )
    f f infer-classes-with ;

: infer-classes/node ( existing node -- )
    #! Infer classes, using the existing node's class info as a
    #! starting point.
    over node-classes rot node-literals infer-classes-with ;
