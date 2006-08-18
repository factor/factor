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
    meta-d get clone >r
    swap make-call-node
    over effect-in length over consume-values
    over effect-out length over produce-values
    r> over #call-label? [ over set-node-in-d ] [ drop ] if
    node, effect-terminated? [ terminate ] when ;

TUPLE: no-effect word ;

: no-effect ( word -- * )
    <no-effect> inference-error ;

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
    dup node-param swap
    [ [ collect-recursion* ] each-node-with ] { } make ;

: join-values ( node -- )
    collect-recursion meta-d get add unify-lengths unify-stacks
    meta-d [ length tail* >vector ] change ;

: splice-node ( node -- )
    dup node-successor [
        dup node, penultimate-node f over set-node-successor
        dup current-node set
    ] when drop ;

: inline-closure ( word -- )
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

M: object apply-word no-effect ;

TUPLE: effect-error word effect ;

: effect-error ( word effect -- * )
    <effect-error> inference-error ;

: check-effect ( word effect -- )
    over "infer" word-prop [
        2drop
    ] [
        over recorded get push
        dup pick "declared-effect" word-prop dup
        [ effect<= [ effect-error ] unless ] [ 2drop ] if
        "infer-effect" set-word-prop
    ] if ;

M: compound apply-word
    [
        dup infer-compound check-effect
    ] [
        swap t "no-effect" set-word-prop rethrow
    ] recover ;

: ?no-effect ( word -- )
    dup "no-effect" word-prop [ no-effect ] [ drop ] if ;

: apply-default ( word -- )
    dup ?no-effect
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

TUPLE: recursive-declare-error word ;

: recursive-effect ( word -- effect )
    dup stack-effect
    [ ] [ <recursive-declare-error> inference-error ] ?if ;

M: compound apply-object
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
