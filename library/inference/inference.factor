! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: arrays errors generic interpreter io kernel lists math
namespaces parser prettyprint sequences strings vectors words ;

! This variable takes a boolean value.
SYMBOL: inferring-base-case

! Called when a recursive call during base case inference is
! found. Either tries to infer another branch, or gives up.
SYMBOL: base-case-continuation

TUPLE: inference-error message rstate data-stack call-stack ;

: inference-error ( msg -- )
    recursive-state get meta-d get meta-r get
    <inference-error> throw ;

M: inference-error error. ( error -- )
    "! Inference error:" print
    dup inference-error-message print
    "! Recursive state:" print
    inference-error-rstate sequence. ;

M: value literal-value ( value -- )
    {
        "A literal value was expected where a computed value was found.\n"
        "This means the word you are inferring applies 'call' or 'execute'\n"
        "to a value that is not known at compile time.\n"
        "See the handbook for details."
    } concat inference-error ;

! Word properties that affect inference:
! - infer-effect -- must be set. controls number of inputs
! expected, and number of outputs produced.
! - infer - quotation with custom inference behavior; ifte uses
! this. Word is passed on the stack.

! Vector of results we had to add to the datastack. Ie, the
! inputs.
SYMBOL: d-in

: pop-literal ( -- rstate obj )
    1 #drop node, pop-d dup value-recursion swap literal-value ;

: value-vector ( n -- vector ) [ drop <value> ] map >vector ;

: required-inputs ( n stack -- n ) length - 0 max ;

: add-inputs ( n stack -- stack )
    tuck required-inputs dup 0 >
    [ value-vector swap append ] [ drop ] ifte ;

: ensure-values ( n -- )
    dup meta-d get required-inputs d-in [ + ] change
    meta-d [ add-inputs ] change ;

: effect ( -- @{ in# out# }@ )
    #! After inference is finished, collect information.
    d-in get meta-d get length 2array ;

: init-inference ( recursive-state -- )
    init-interpreter
    0 d-in set
    recursive-state set
    dataflow-graph off
    current-node off ;

GENERIC: apply-object

: apply-literal ( obj -- )
    #! Literals are annotated with the current recursive
    #! state.
    <literal> push-d  1 #push node, ;

M: object apply-object apply-literal ;

M: wrapper apply-object wrapped apply-literal ;

: active? ( -- ? )
    #! Is this branch not terminated?
    meta-d get meta-r get and ;

: terminate ( -- )
    #! Ignore this branch's stack effect.
    d-in off meta-d off meta-r off #terminate node, ;

: infer-quot ( quot -- )
    #! Recursive calls to this word are made for nested
    #! quotations.
    [ active? [ apply-object t ] [ drop f ] ifte ] all? drop ;

: infer-quot-value ( rstate quot -- )
    recursive-state get >r swap recursive-state set
    infer-quot r> recursive-state set ;

: check-return ( -- )
    #! Raise an error if word leaves values on return stack.
    meta-r get empty? [
        "Word leaves " meta-r get length number>string
        " element(s) on return stack. Check >r/r> usage." append3
        inference-error
    ] unless ;

: with-infer ( quot -- )
    [
        inferring-base-case off
        base-case-continuation off
        f init-inference
        call
        check-return
    ] with-scope ;

: infer ( quot -- effect )
    #! Stack effect of a quotation.
    [ infer-quot effect ] with-infer ;

: (dataflow) ( quot -- dataflow )
    infer-quot f #return node, dataflow-graph get ;

: dataflow ( quot -- dataflow )
    #! Data flow of a quotation.
    [ (dataflow) ] with-infer ;

: dataflow-with ( quot stack -- effect )
    #! Infer starting from a stack of values.
    [ meta-d set (dataflow) ] with-infer ;
