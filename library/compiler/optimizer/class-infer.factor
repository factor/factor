! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: optimizer
USING: arrays generic hashtables inference kernel
kernel-internals math namespaces sequences words ;

! Infer possible classes of values in a dataflow IR.

: node-class ( value node -- class )
    node-classes ?hash [ object ] unless* ;

: node-class# ( node n -- class )
    swap [ node-in-d reverse-slice ?nth ] keep node-class ;

! Variables used by the class inferencer

! Current value --> class mapping
SYMBOL: value-classes

! Current value --> literal mapping
SYMBOL: value-literals

! Maps ties to ties
SYMBOL: ties

GENERIC: apply-tie ( tie -- )

M: f apply-tie ( f -- ) drop ;

TUPLE: class-tie value class ;

: set-value-class* ( class value -- )
    2dup swap <class-tie> ties get hash [ apply-tie ] when*
    value-classes get set-hash ;

M: class-tie apply-tie ( tie -- )
    dup class-tie-class swap class-tie-value
    set-value-class* ;

TUPLE: literal-tie value literal ;

: set-value-literal* ( literal value -- )
    over class over set-value-class*
    2dup swap <literal-tie> ties get hash [ apply-tie ] when*
    value-literals get set-hash ;

M: literal-tie apply-tie ( tie -- )
    dup literal-tie-literal swap literal-tie-value
    set-value-literal* ;

GENERIC: infer-classes* ( node -- )

M: node infer-classes* ( node -- ) drop ;

! For conditionals, a map of child node # --> possibility
GENERIC: child-ties ( node -- seq )

M: node child-ties ( node -- seq )
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

\ make-tuple [
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
        node-param "infer-effect" word-prop second
        dup integer? [ drop f ] when
    ] if* ;

M: #call infer-classes* ( node -- )
    dup create-ties dup output-classes
    [ swap node-out-d intersect-classes ] [ drop ] if* ;

M: #push infer-classes* ( node -- )
    node-out-d
    [ [ value-literal ] keep set-value-literal* ] each ;

M: #if child-ties ( node -- seq )
    node-in-d first dup general-t <class-tie>
    swap f <literal-tie> 2array ;

M: #dispatch child-ties ( node -- seq )
    dup node-in-d first
    swap node-children length [ <literal-tie> ] map-with ;

M: #declare infer-classes* ( node -- )
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

: (infer-classes) ( node -- )
    [
        dup infer-classes*
        dup annotate-node
        dup infer-children
        node-successor (infer-classes)
    ] when* ;

: infer-classes ( node -- )
    [
        H{ } clone value-classes set
        H{ } clone value-literals set
        H{ } clone ties set
        (infer-classes)
    ] with-scope ;
