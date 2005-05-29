! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors generic interpreter kernel lists math namespaces
prettyprint sequences strings unparser vectors words ;

! This variable takes a boolean value.
SYMBOL: inferring-base-case

! Word properties that affect inference:
! - infer-effect -- must be set. controls number of inputs
! expected, and number of outputs produced.
! - infer - quotation with custom inference behavior; ifte uses
! this. Word is passed on the stack.

! Vector of results we had to add to the datastack. Ie, the
! inputs.
SYMBOL: d-in

: pop-literal ( -- rstate obj )
    1 #drop node, pop-d >literal< ;

: (ensure-types) ( typelist n stack -- )
    pick [
        3dup >r >r car r> r> nth value-class-and
        >r >r cdr r> 1 + r> (ensure-types)
    ] [
        3drop
    ] ifte ;

: ensure-types ( typelist stack -- )
    dup length pick length - dup 0 < [
        swap >r neg swap tail 0 r>
    ] [
        swap
    ] ifte (ensure-types) ;

: required-inputs ( typelist stack -- values )
    >r dup length r> length - dup 0 > [
        swap head [ <computed> ] map
    ] [
        2drop f
    ] ifte ;

: ensure-d ( typelist -- )
    dup meta-d get ensure-types
    meta-d get required-inputs >vector dup
    meta-d [ append ] change
    d-in [ append ] change ;

: hairy-node ( node effect quot -- )
    over car ensure-d
    -rot 2dup car length 0 rot node-inputs
    2slip
    second length 0 rot node-outputs ; inline

: (present-effect) ( vector -- list )
    >list [ value-class ] map ;

: present-effect ( [[ d-in meta-d ]] -- [ in-types out-types ] )
    #! After inference is finished, collect information.
    uncons >r (present-effect) r> (present-effect) 2list ;

: simple-effect ( [[ d-in meta-d ]] -- [[ in# out# ]] )
    #! After inference is finished, collect information.
    uncons length >r length r> cons ;

: init-inference ( recursive-state -- )
    init-interpreter
    0 <vector> d-in set
    recursive-state set
    dataflow-graph off
    current-node off ;

GENERIC: apply-object

: apply-literal ( obj -- )
    #! Literals are annotated with the current recursive
    #! state.
    recursive-state get <literal> push-d  1 #push node, ;

M: object apply-object apply-literal ;

: active? ( -- ? )
    #! Is this branch not terminated?
    d-in get meta-d get and ;

: effect ( -- [[ d-in meta-d ]] )
    d-in get meta-d get cons ;

: terminate ( -- )
    #! Ignore this branch's stack effect.
    meta-d off meta-r off d-in off ;

: terminator? ( obj -- ? )
    #! Does it throw an error?
    dup word? [ "terminator" word-prop ] [ drop f ] ifte ;

: handle-terminator ( quot -- )
    #! If the quotation throws an error, do not count its stack
    #! effect.
    [ terminator? ] some? [ terminate ] when ;

: infer-quot ( quot -- )
    #! Recursive calls to this word are made for nested
    #! quotations.
    active? [
        [ unswons apply-object infer-quot ] when*
    ] [
        drop
    ] ifte ;

: infer-quot-value ( rstate quot -- )
    recursive-state get >r
    swap recursive-state set
    dup infer-quot handle-terminator
    r> recursive-state set ;

: check-active ( -- )
    active? [ "Provable runtime error" inference-error ] unless ;

: check-return ( -- )
    #! Raise an error if word leaves values on return stack.
    meta-r get empty? [
        "Word leaves elements on return stack" inference-error
    ] unless ;

: with-infer ( quot -- )
    [
        inferring-base-case off
        f init-inference
        call
        check-active
        check-return
    ] with-scope ;

: infer ( quot -- effect )
    #! Stack effect of a quotation.
    [ infer-quot effect present-effect ] with-infer ;

: dataflow ( quot -- dataflow )
    #! Data flow of a quotation.
    [ infer-quot #return node, dataflow-graph get ] with-infer ;
