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

: recursing? ( word -- label/f )
    recursive-state get <reversed> assoc ;

: make-call-node ( word -- node )
    dup "inline" word-prop
    [ dup recursing? [ #call-label ] [ #call ] ?if ]
    [ #call ]
    if ;

: consume/produce ( word effect -- )
    #! Add a node to the dataflow graph that consumes and
    #! produces a number of values.
    meta-d get clone >r
    swap make-call-node
    over effect-in length over consume-values
    over effect-out length over produce-values
    r> over #call-label? [ over set-node-in-d ] [ drop ] if
    node, effect-terminated? [ terminate ] when ;

: no-effect ( word -- * )
    "Stack effect inference of the word " swap word-name
    " was already attempted, and failed" append3
    inference-error ;

: nest-node ( -- ) #entry node, ;

: unnest-node ( new-node -- new-node )
    dup node-param #return node,
    dataflow-graph get 1array over set-node-children ;

: add-recursive-state ( word label -- )
    2array recursive-state [ swap add ] change ;

: inline-block ( word -- node-block variables )
    [
        copy-inference nest-node
        gensym 2dup add-recursive-state
        #label >r word-def infer-quot r>
        unnest-node
    ] make-hash ;

: apply-infer ( hash -- )
    { meta-d meta-r d-in }
    [ [ swap hash ] keep set ] each-with ;

GENERIC: collect-recursion* ( label node -- )

M: node collect-recursion* 2drop ;

M: #call-label collect-recursion*
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
    meta-d [ length tail* >vector ] change ;

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
    dup inline-block over recursive-label? [
        meta-d get >r
        drop join-values inline-block apply-infer
        r> over set-node-in-d node,
    ] [
        apply-infer node-child node-successor splice-node drop
    ] if ;

: infer-compound ( word -- effect )
    [
        recursive-state get init-inference
        [ inline-block nip [ current-effect ] bind ] keep
    ] with-scope over consume/produce ;

GENERIC: apply-word

M: object apply-word
    #! A primitive with an unknown stack effect.
    no-effect ;

TUPLE: effect-error word effect ;

: effect-error ( word effect -- * ) <effect-error> throw ;

: check-effect ( word effect -- )
    over recorded get push
    dup pick "declared-effect" word-prop dup
    [ effect<= [ effect-error ] unless ] [ 2drop ] if
    "infer-effect" set-word-prop ;

M: compound apply-word
    #! Infer a compound word's stack effect.
    [
        dup infer-compound check-effect
    ] [
        swap t "no-effect" set-word-prop rethrow
    ] recover ;

: apply-default ( word -- )
    dup "no-effect" word-prop [ no-effect ] when
    dup "infer-effect" word-prop [
        over "infer" word-prop [
            swap effect-in length ensure-values call drop
        ] [
            consume/produce
        ] if*
    ] [
        apply-word
    ] if* ;

M: word apply-object apply-default ;

M: symbol apply-object apply-literal ;

: declared-effect ( word -- effect )
    dup "declared-effect" word-prop [ ] [
        "The recursive word " swap word-name
        " does not declare a stack effect" append3
        inference-error
    ] ?if ;

: recursive-effect ( word -- effect )
    #! Handle a recursive call, by either applying a previously
    #! inferred base case, or raising an error. If the recursive
    #! call is to a local block, emit a label call node.
    dup "infer-effect" word-prop [ ] [ declared-effect ] if ;

M: compound apply-object
    #! Apply the word's stack effect to the inferencer state.
    dup "inline" word-prop [
        dup recursive-state get peek first eq? [
            dup recursive-effect consume/produce
        ] [
            inline-closure
        ] if
    ] [
        dup recursing? [
            dup recursive-effect consume/produce
        ] [
            apply-default
        ] if
    ] if ;
