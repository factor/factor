! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference
USING: arrays errors generic inspector interpreter io kernel
math namespaces parser prettyprint sequences strings
vectors words ;

TUPLE: inference-error message rstate data-stack call-stack ;

: inference-error ( msg -- * )
    recursive-state get meta-d get meta-r get
    <inference-error> throw ;

M: object value-literal
    "A literal value was expected where a computed value was found" inference-error ;

! Word properties that affect inference:
! - infer-effect -- must be set. controls number of inputs
! expected, and number of outputs produced.
! - infer - quotation with custom inference behavior; 'if' uses
! this. Word is passed on the stack.

! Number of values we had to add to the datastack. Ie, the
! inputs.
SYMBOL: d-in

: pop-literal ( -- rstate obj )
    1 #drop node,
    pop-d dup value-recursion swap value-literal ;

: value-vector ( n -- vector ) [ drop <computed> ] map >vector ;

: add-inputs ( n stack -- n stack )
    tuck length - dup 0 >
    [ dup value-vector [ rot nappend ] keep ]
    [ drop 0 swap ] if ;

: ensure-values ( n -- )
    meta-d [ add-inputs ] change d-in [ + ] change ;

: short-effect ( -- pair )
    d-in get meta-d get length 2array ;

! Does this control flow path throw an exception, therefore its
! stack height is irrelevant and the branch will always unify?
SYMBOL: terminated?

: current-effect ( -- effect )
    d-in get meta-d get length <effect>
    terminated? get over set-effect-terminated? ;

SYMBOL: recorded

: init-inference ( recursive-state -- )
    terminated? off
    V{ } clone meta-r set
    V{ } clone meta-d set
    0 d-in set
    recursive-state set
    dataflow-graph off
    current-node off ;

GENERIC: apply-object

: apply-literal ( obj -- )
    #! Literals are annotated with the current recursive
    #! state.
    <value> push-d #push node, ;

M: object apply-object apply-literal ;

M: wrapper apply-object wrapped apply-literal ;

: terminate ( -- )
    #! Ignore this branch's stack effect.
    terminated? on #terminate node, ;

GENERIC: infer-quot ( quot -- )

M: f infer-quot drop ;

M: quotation infer-quot
    #! Recursive calls to this word are made for nested
    #! quotations.
    [ apply-object terminated? get not ] all? drop ;

: infer-quot-value ( rstate quot -- )
    recursive-state get >r swap recursive-state set
    infer-quot r> recursive-state set ;

: check-return ( -- )
    #! Raise an error if word leaves values on return stack.
    meta-r get empty? [
        "Word leaves " meta-r get length number>string
        " element(s) on retain stack. Check >r/r> usage." append3
        inference-error
    ] unless ;

: undo-infer ( -- )
    recorded get
    [ "infer" word-prop not ] subset
    [ f "infer-effect" set-word-prop ] each ;

: with-infer ( quot -- )
    [
        [
            { } recursive-state set
            V{ } clone recorded set
            f init-inference
            call
            check-return
        ] [
            undo-infer
            rethrow
        ] recover
    ] with-scope ;

: infer ( quot -- effect )
    #! Stack effect of a quotation.
    [ infer-quot short-effect ] with-infer ;

: (dataflow) ( quot -- dataflow )
    infer-quot f #return node, dataflow-graph get ;

: dataflow ( quot -- dataflow )
    #! Data flow of a quotation.
    [ (dataflow) ] with-infer ;

: dataflow-with ( quot stack -- effect )
    #! Infer starting from a stack of values.
    [ meta-d set (dataflow) ] with-infer ;
