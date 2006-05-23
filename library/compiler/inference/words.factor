! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays errors generic hashtables interpreter kernel
math math-internals namespaces parser prettyprint sequences
strings vectors words ;
IN: inference

: consume-values ( n node -- )
    over ensure-values
    over 0 rot node-inputs [ pop-d 2drop ] each ;

: produce-values ( n node -- )
    over [ drop <computed> push-d ] each 0 swap node-outputs ;

: consume/produce ( word effect -- )
    #! Add a node to the dataflow graph that consumes and
    #! produces a number of values.
    swap #call
    over first length over consume-values
    swap second length over produce-values
    node, ;

: no-effect ( word -- )
    "Stack effect inference of the word " swap word-name
    " was already attempted, and failed" append3
    inference-error ;

TUPLE: rstate label base-case? ;

: nest-node ( -- dataflow current )
    dataflow-graph get  dataflow-graph off
    current-node get    current-node off ;

: unnest-node ( new-node dataflow current -- new-node )
    >r >r dataflow-graph get 1array over set-node-children
    r> dataflow-graph set
    r> current-node set ;

: with-recursive-state ( word label base-case quot -- )
    >r <rstate> 2array recursive-state [ swap add ] change r>
    nest-node 2slip unnest-node ; inline

: inline-block ( word base-case -- node-block variables )
    [
        copy-inference
        >r gensym 2dup r> [
            dup #label >r
            #entry node,
            swap word-def infer-quot
            #return node, r>
        ] with-recursive-state
    ] make-hash ;

: apply-infer ( hash -- )
    { meta-d meta-r d-in }
    [ [ swap hash ] keep set ] each-with ;

GENERIC: collect-recursion* ( label node -- )

M: node collect-recursion* ( label node -- ) 2drop ;

M: #call-label collect-recursion* ( label node -- )
    tuck node-param = [ node-in-d , ] [ drop ] if ;

: collect-recursion ( #label -- seq )
    #! Collect the input stacks of all #call-label nodes that
    #! call given label.
    dup node-param swap
    [ [ collect-recursion* ] each-node-with ] { } make ;

: join-values ( node -- )
    #! We have to infer recursive labels twice to determine
    #! which literals survive the recursion (eg, quotations)
    #! and which don't (loop indices, etc). The latter cannot
    #! be folded.
    collect-recursion meta-d get add unify-stacks
    meta-d [ length swap tail* ] change ;

: splice-node ( node -- )
    #! Labels which do not call themselves are just spliced into
    #! the IR, and no #label node is added.
    dup node-successor [
        dup node, penultimate-node f over set-node-successor
        dup current-node set
    ] when drop ;

: inline-closure ( word -- )
    #! This is not a closure in the lexical scope sense, but a
    #! closure under recursive value substitution.
    #! If the block does not call itself, there is no point in
    #! having the block node in the IR. Just add its contents.
    dup f inline-block over recursive-label? [
        meta-d get >r
        drop join-values f inline-block apply-infer
        r> over set-node-in-d node,
    ] [
        apply-infer node-child node-successor splice-node drop
    ] if ;

: infer-compound ( word base-case -- terminates? effect )
    #! Infer a word's stack effect in a separate inferencer
    #! instance. Outputs a true boolean if the word terminates
    #! control flow by throwing an exception or restoring a
    #! continuation.
    [
        dup inferring-base-case set
        recursive-state get init-inference
        over >r inline-block nip
        [ terminated? get effect ] bind r>
    ] with-scope over consume/produce over [ terminate ] when ;

GENERIC: apply-word

M: object apply-word ( word -- )
    #! A primitive with an unknown stack effect.
    no-effect ;

: save-effect ( word terminates effect -- )
    inferring-base-case get [
        3drop
    ] [
        >r dupd "terminates" set-word-prop r>
        "infer-effect" set-word-prop
    ] if ;

M: compound apply-word ( word -- )
    #! Infer a compound word's stack effect.
    [
        dup f infer-compound save-effect
    ] [
        swap t "no-effect" set-word-prop rethrow
    ] recover ;

: apply-default ( word -- )
    dup "no-effect" word-prop [
        no-effect
    ] [
        dup "infer-effect" word-prop [
            over "infer" word-prop [
                swap first length ensure-values call drop
            ] [
                dupd consume/produce
                "terminates" word-prop [ terminate ] when
            ] if*
        ] [
            apply-word
        ] if*
    ] if ;

M: word apply-object ( word -- )
    apply-default ;

M: symbol apply-object ( word -- )
    apply-literal ;

: inline-base-case ( word label -- )
    meta-d get clone >r over t inline-block apply-infer drop
    [ #call-label ] [ #call ] ?if r> over set-node-in-d node, ;

: base-case ( word label -- )
    over "inline" word-prop [
        inline-base-case
    ] [
        drop dup t infer-compound swap
        [ 2drop ] [ "base-case" set-word-prop ] if
    ] if ;

: no-base-case ( word -- )
    {
        "The base case of a recursive word could not be inferred.\n"
        "This means the word calls itself in every control flow path.\n"
        "See the documentation for details."
    } concat inference-error ;

: notify-base-case ( -- )
    base-case-continuation get
    [ t swap continue-with ] [ no-base-case ] if* ;

: recursive-word ( word rstate -- )
    #! Handle a recursive call, by either applying a previously
    #! inferred base case, or raising an error. If the recursive
    #! call is to a local block, emit a label call node.
    over "infer-effect" word-prop [
        nip consume/produce
    ] [
        over "base-case" word-prop [
            nip consume/produce
        ] [
            dup rstate-base-case? [
                notify-base-case
            ] [
                rstate-label base-case
            ] if
        ] if*
    ] if* ;

M: compound apply-object ( word -- )
    #! Apply the word's stack effect to the inferencer state.
    dup recursive-state get <reversed> assoc [
        recursive-word
    ] [
        dup "inline" word-prop
        [ inline-closure ] [ apply-default ] if
    ] if* ;
