! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors generic interpreter io kernel lists math
namespaces parser prettyprint sequences strings vectors words ;

! This variable takes a boolean value.
SYMBOL: inferring-base-case

TUPLE: inference-error message rstate data-stack call-stack ;

: inference-error ( msg -- )
    recursive-state get meta-d get meta-r get
    <inference-error> throw ;

M: inference-error error. ( error -- )
    "! Inference error:" print
    dup inference-error-message print
    "! Recursive state:" print
    inference-error-rstate [.] ;

M: value literal-value ( value -- )
    {
        "A literal value was expected where a computed value was found.\n"
        "This means that an attempt was made to compile a word that\n"
        "applies 'call' or 'execute' to a value that is not known\n"
        "at compile time. The value might become known if the word\n"
        "is marked 'inline'. See the handbook for details."
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

: computed-value-vector ( n -- vector )
    empty-vector dup [ drop <computed> ] nmap ;

: required-inputs ( n stack -- values )
    length - 0 max computed-value-vector ;

: ensure-d ( typelist -- )
    length meta-d get required-inputs dup
    meta-d [ append ] change
    d-in [ append ] change ;

: hairy-node ( node effect quot -- )
    over car ensure-d
    -rot 2dup car length 0 rot node-inputs
    2slip
    second length 0 rot node-outputs ; inline

: effect ( -- [[ in# out# ]] )
    #! After inference is finished, collect information.
    d-in get length object <repeated> >list
    meta-d get length object <repeated> >list 2list ;

: init-inference ( recursive-state -- )
    init-interpreter
    { } clone d-in set
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
    d-in get meta-d get and ;

: terminate ( -- )
    #! Ignore this branch's stack effect.
    meta-d off meta-r off d-in off ;

: terminator? ( obj -- ? )
    #! Does it throw an error?
    dup word? [ "terminator" word-prop ] [ drop f ] ifte ;

: handle-terminator ( quot -- )
    #! If the quotation throws an error, do not count its stack
    #! effect.
    [ terminator? ] contains? [ terminate ] when ;

: infer-quot ( quot -- )
    #! Recursive calls to this word are made for nested
    #! quotations.
    [ active? [ apply-object t ] [ drop f ] ifte ] all? drop ;

: infer-quot-value ( rstate quot -- )
    recursive-state get >r
    swap recursive-state set
    dup infer-quot handle-terminator
    r> recursive-state set ;

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
        f init-inference
        call
        check-return
    ] with-scope ;

: infer ( quot -- effect )
    #! Stack effect of a quotation.
    [ infer-quot effect ] with-infer ;

: (dataflow) ( quot -- dataflow )
    infer-quot #return node, dataflow-graph get ;

: dataflow ( quot -- dataflow )
    #! Data flow of a quotation.
    [ (dataflow) ] with-infer ;

: dataflow-with ( quot stack -- effect )
    #! Infer starting from a stack of values.
    [ meta-d set (dataflow) ] with-infer ;
