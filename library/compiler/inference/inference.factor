! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference
USING: arrays errors generic inspector interpreter io kernel
math namespaces parser prettyprint sequences strings
vectors words ;

TUPLE: inference-error rstate ;

C: inference-error ( msg rstate -- error )
    [ set-inference-error-rstate ] keep
    [ set-delegate ] keep ;

: inference-error ( msg -- * )
    recursive-state get <inference-error> throw ;

TUPLE: literal-expected ;

M: object value-literal
    <literal-expected> inference-error ;

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
    <value> push-d #push node, ;

M: object apply-object apply-literal ;

M: wrapper apply-object wrapped apply-literal ;

: terminate ( -- )
    terminated? on #terminate node, ;

GENERIC: infer-quot ( quot -- )

M: f infer-quot drop ;

M: quotation infer-quot
    [ apply-object terminated? get not ] all? drop ;

: infer-quot-value ( rstate quot -- )
    recursive-state get >r swap recursive-state set
    infer-quot r> recursive-state set ;

TUPLE: check-return ;

: check-return ( -- )
    meta-r get empty? [
        <check-return> inference-error
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
    [ infer-quot short-effect ] with-infer ;

: (dataflow) ( quot -- dataflow )
    infer-quot f #return node, dataflow-graph get ;

: dataflow ( quot -- dataflow )
    [ (dataflow) ] with-infer ;

: dataflow-with ( quot stack -- effect )
    [ meta-d set (dataflow) ] with-infer ;
