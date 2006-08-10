! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays errors generic hashtables interpreter kernel
math math-internals namespaces parser prettyprint sequences
strings vectors words ;
IN: inference

: consume-values ( n node -- )
    over ensure-values
    over 0 rot node-inputs
    meta-d get [ length swap - ] keep set-length ;

: produce-values ( n node -- )
    >r [ drop <computed> ] map dup r> set-node-out-d
    meta-d get swap nappend ;

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

: nest-node ( -- ) #entry node, ;

: unnest-node ( new-node -- new-node )
    dup node-param #return node,
    dataflow-graph get 1array over set-node-children ;

: add-recursive-state ( word label base-case -- )
    <rstate> 2array recursive-state [ swap add ] change ;

: inline-block ( word base-case -- node-block variables )
    [
        copy-inference nest-node
        >r gensym 2dup r> add-recursive-state
        #label >r word-def infer-quot r>
        unnest-node
    ] make-hash ;

: apply-infer ( hash -- )
    { meta-d meta-r d-in }
    [ [ swap hash ] keep set ] each-with ;

GENERIC: collect-recursion* ( label node -- )

M: node collect-recursion* ( label node -- ) 2drop ;

M: #call-label collect-recursion* ( label node -- )
    tuck node-param eq? [ node-in-d , ] [ drop ] if ;

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
    collect-recursion meta-d get add unify-lengths unify-stacks
    meta-d [ length tail* ] change ;

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
        recursive-state get init-inference
        over >r inline-block nip
        [ terminated? get effect ] bind r>
    ] with-scope over consume/produce over [ terminate ] when ;

GENERIC: apply-word

M: object apply-word ( word -- )
    #! A primitive with an unknown stack effect.
    no-effect ;

: save-effect ( word terminates effect prop -- )
    rot [ 3drop ] [ set-word-prop ] if ;

M: compound apply-word ( word -- )
    #! Infer a compound word's stack effect.
    [
        dup f infer-compound "infer-effect" save-effect
    ] [
        swap t "no-effect" set-word-prop rethrow
    ] recover ;

: apply-default ( word -- )
    dup "no-effect" word-prop [ no-effect ] when
    dup "infer-effect" word-prop [
        over "infer" word-prop [
            swap first length ensure-values call drop
        ] [
            consume/produce
        ] if*
    ] [
        apply-word
    ] if* ;

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
        drop dup t infer-compound "base-case" save-effect
    ] if ;

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
