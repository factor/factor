! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic interpreter kernel lists math namespaces strings
unparser vectors words ;

: max-recursion 0 ;

! This variable takes a value from 0 up to max-recursion.
SYMBOL: inferring-base-case

: branches-can-fail? ( -- ? )
    inferring-base-case get max-recursion > ;

! Word properties that affect inference:
! - infer-effect -- must be set. controls number of inputs
! expected, and number of outputs produced.
! - infer - quotation with custom inference behavior; ifte uses
! this. Word is passed on the stack.

! Vector of results we had to add to the datastack. Ie, the
! inputs.
SYMBOL: d-in

! Recursive state. An alist, mapping words to labels.
SYMBOL: recursive-state

GENERIC: value= ( literal value -- ? )
GENERIC: value-class-and ( class value -- )

TUPLE: value class recursion class-ties literal-ties ;

C: value ( recursion -- value )
    [ set-value-recursion ] keep ;

TUPLE: computed delegate ;

C: computed ( class -- value )
    swap recursive-state get <value> [ set-value-class ] keep
    over set-computed-delegate ;

M: computed value= ( literal value -- ? )
    2drop f ;

: failing-class-and ( class class -- class )
    2dup class-and dup null = [
        drop [
            word-name , " and " , word-name ,
            " do not intersect" ,
        ] make-string inference-error
    ] [
        2nip
    ] ifte ;

M: computed value-class-and ( class value -- )
    [
        value-class failing-class-and
    ] keep set-value-class ;

TUPLE: literal value delegate ;

C: literal ( obj rstate -- value )
    [
        >r <value> [ >r dup class r> set-value-class ] keep
        r> set-literal-delegate
    ] keep
    [ set-literal-value ] keep ;

M: literal value= ( literal value -- ? )
    literal-value = ;

M: literal value-class-and ( class value -- )
    value-class class-and drop ;

M: literal set-value-class ( class value -- )
    2drop ;

M: computed literal-value ( value -- )
    "A literal value was expected where a computed value was"
    " found: " rot unparse cat3 inference-error ;

: (ensure-types) ( typelist n stack -- )
    pick [
        3dup >r >r car r> r> vector-nth value-class-and
        >r >r cdr r> 1 + r> (ensure-types)
    ] [
        3drop
    ] ifte ;

: ensure-types ( typelist stack -- )
    dup vector-length pick length - dup 0 < [
        swap >r neg tail 0 r>
    ] [
        swap
    ] ifte (ensure-types) ;

: required-inputs ( typelist stack -- values )
    >r dup length r> vector-length - dup 0 > [
        head [ <computed> ] map
    ] [
        2drop f
    ] ifte ;

: vector-prepend ( values stack -- stack )
    >r list>vector r> vector-append ;

: ensure-d ( typelist -- )
    dup meta-d get ensure-types
    meta-d get required-inputs dup
    meta-d [ vector-prepend ] change
    d-in [ vector-prepend ] change ;

: (present-effect) ( vector -- list )
    [ value-class ] vector-map vector>list ;

: present-effect ( [[ d-in meta-d ]] -- [ in-types out-types ] )
    #! After inference is finished, collect information.
    uncons >r (present-effect) r> (present-effect) 2list ;

: simple-effect ( [[ d-in meta-d ]] -- [[ in# out# ]] )
    #! After inference is finished, collect information.
    uncons vector-length >r vector-length r> cons ;

: init-inference ( recursive-state -- )
    init-interpreter
    0 <vector> d-in set
    recursive-state set
    dataflow-graph off
    0 inferring-base-case set ;

GENERIC: apply-object

: apply-literal ( obj -- )
    #! Literals are annotated with the current recursive
    #! state.
    dup recursive-state get <literal> push-d
    #push dataflow, [ 1 0 node-outputs ] bind ;

M: object apply-object apply-literal ;

: active? ( -- ? )
    #! Is this branch not terminated?
    d-in get meta-d get and ;

: check-active ( -- )
    active? [
         "Provable runtime error" inference-error
    ] unless ;

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

: check-return ( -- )
    #! Raise an error if word leaves values on return stack.
    meta-r get vector-length 0 = [
        "Word leaves elements on return stack" inference-error
    ] unless ;

: values-node ( op -- )
    #! Add a #values or #return node to the graph.
    f swap dataflow, [
        meta-d get vector>list node-consume-d set
    ] bind ;

: (infer) ( quot -- )
    f init-inference
    infer-quot
    check-active
    #return values-node check-return ;

: infer ( quot -- [[ in out ]] )
    #! Stack effect of a quotation.
    [ (infer) effect present-effect ] with-scope ;

: dataflow ( quot -- dataflow )
    #! Data flow of a quotation.
    [ (infer) get-dataflow ] with-scope ;
