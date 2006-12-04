! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference
USING: arrays errors generic io kernel
math namespaces parser prettyprint sequences strings
vectors words tools ;

TUPLE: inference-error rstate major? ;

C: inference-error ( msg rstate important? -- error )
    [ set-inference-error-major? ] keep
    [ set-inference-error-rstate ] keep
    [ set-delegate ] keep ;

: inference-error ( msg -- * )
    recursive-state get t <inference-error> throw ;

: inference-warning ( msg -- * )
    recursive-state get f <inference-error> throw ;

TUPLE: literal-expected ;

M: object value-literal
    <literal-expected> inference-warning ;

: pop-literal ( -- rstate obj )
    1 #drop node,
    pop-d dup value-recursion swap value-literal ;

: value-vector ( n -- vector ) [ drop <computed> ] map >vector ;

: add-inputs ( seq stack -- n stack )
    tuck [ length ] 2apply - dup 0 >
    [ dup value-vector [ rot nappend ] keep ]
    [ drop 0 swap ] if ;

: ensure-values ( seq -- )
    meta-d [ add-inputs ] change d-in [ + ] change ;

SYMBOL: terminated?

: current-effect ( -- effect )
    d-in get meta-d get length <effect>
    terminated? get over set-effect-terminated? ;

SYMBOL: recorded

: init-inference ( recursive-state -- )
    terminated? off
    V{ } clone meta-d set
    V{ } clone meta-r set
    V{ } clone meta-n set
    empty-vars inferred-vars set
    0 d-in set
    recursive-state set
    dataflow-graph off
    current-node off ;

GENERIC: apply-object ( obj -- )

: apply-literal ( obj -- )
    #push dup node,
    swap <value> push-d
    1 d-tail swap set-node-out-d ;

M: object apply-object apply-literal ;

M: wrapper apply-object wrapped apply-literal ;

GENERIC: apply-word ( word -- )

M: word apply-object apply-word ;

: terminate ( -- )
    terminated? on #terminate node, ;

GENERIC: infer-quot ( quot -- )

M: f infer-quot drop ;

M: quotation infer-quot
    [ apply-object terminated? get not ] all? drop ;

: infer-quot-value ( rstate quot -- )
    recursive-state get >r swap recursive-state set
    infer-quot r> recursive-state set ;

TUPLE: too-many->r ;

: check->r ( -- )
    meta-r get empty? [
        <too-many->r> inference-error
    ] unless ;

TUPLE: too-many-r> ;

: check-r> ( -- )
    meta-r get empty? [
        <too-many-r>> inference-error
    ] when ;

: undo-infer ( -- )
    recorded get [ custom-infer? not ] subset [
        dup
        f "inferred-vars" set-word-prop
        f "inferred-effect" set-word-prop
    ] each ;

: with-infer ( quot -- )
    [
        [
            { } recursive-state set
            V{ } clone recorded set
            f init-inference
            call
            check->r
        ] [
            undo-infer
            rethrow
        ] recover
    ] with-scope ;

: infer ( quot -- effect infer-vars )
    [ infer-quot inferred-vars get current-effect ] with-infer ;

: vars. ( seq str -- )
    over empty? [ 2drop ] [ print [ . ] each ] if ;

: infer. ( quot -- )
    infer
    "* Stack effect:" print effect>string print
    dup inferred-vars-reads "* Reads free variables:" vars.
    dup inferred-vars-writes "* Writes free variables:" vars.
    dup inferred-vars-reads-globals "* Reads global variables:" vars.
    inferred-vars-writes-globals "* Writes global variables:" vars. ;

: (dataflow) ( quot -- dataflow )
    infer-quot f #return node, dataflow-graph get ;

: dataflow ( quot -- dataflow )
    [ (dataflow) ] with-infer ;

: dataflow-with ( quot stack -- effect )
    [ meta-d set (dataflow) ] with-infer ;
