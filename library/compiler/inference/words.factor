! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays errors generic hashtables kernel
math math-internals namespaces parser prettyprint sequences
strings vectors words ;
IN: inference

: consume-values ( seq node -- )
    >r length r>
    over ensure-values
    over 0 rot node-inputs
    meta-d get [ length swap - ] keep set-length ;

: produce-values ( seq node -- )
    >r [ drop <computed> ] map dup r> set-node-out-d
    meta-d get swap nappend ;

: recursing? ( word -- label/f )
    recursive-state get <reversed> assoc ;

: if-inline ( word true false -- )
    >r >r dup "inline" word-prop r> r> if ; inline

: make-call-node ( word -- node )
    [ dup recursing? [ #call-label ] [ #call ] ?if ]
    [ #call ]
    if-inline ;

: consume/produce ( effect word -- )
    meta-d get clone >r
    swap make-call-node dup node,
    over effect-in over consume-values
    over effect-out over produce-values
    r> over #call-label? [ swap set-node-in-d ] [ 2drop ] if
    effect-terminated? [ terminate ] when ;

TUPLE: no-effect word ;

: no-effect ( word -- * )
    <no-effect> inference-warning ;

: nest-node ( -- ) #entry node, ;

: unnest-node ( new-node -- new-node )
    dup node-param #return node,
    dataflow-graph get 1array over set-node-children ;

: add-recursive-state ( word label -- )
    2array recursive-state [ swap add ] change ;

: inline-block ( word -- node-block data )
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

: infer-compound ( word -- hash )
    [
        recursive-state get init-inference inline-block nip
    ] with-scope ;

GENERIC: infer-word ( word -- effect data )

M: word infer-word no-effect ;

TUPLE: effect-error word effect ;

: effect-error ( word effect -- * )
    <effect-error> inference-error ;

: check-effect ( word effect -- )
    over "infer" word-prop [
        over recorded get push
        over "declared-effect" word-prop 2dup
        [ swap effect<= [ effect-error ] unless ] [ 2drop ] if
    ] unless 2drop ;

: save-inferred-data ( word effect vars -- )
    >r over r>
    dup vars-trivial? [ drop f ] when
    "inferred-vars" set-word-prop
    "inferred-effect" set-word-prop ;

: finish-word ( word -- effect vars )
    current-effect inferred-vars get
    pick custom-infer? [
        rot drop
    ] [
        >r 2dup check-effect r>
        [ save-inferred-data ] 2keep
    ] if ;

M: compound infer-word
    [ dup infer-compound [ finish-word ] bind ]
    [ swap t "no-effect" set-word-prop rethrow ] recover ;

: custom-infer ( word -- )
    #! Customized inference behavior
    dup "inferred-vars" word-prop apply-vars
    dup "inferred-effect" word-prop effect-in ensure-values
    "infer" word-prop call ;

: apply-effect/vars ( word effect vars -- )
    apply-vars consume/produce ;

: cached-infer ( word -- )
    dup "inferred-effect" word-prop
    over "inferred-vars" word-prop
    apply-effect/vars ;

: apply-word ( word -- )
    {
        { [ dup "no-effect" word-prop ] [ no-effect ] }
        { [ dup "infer" word-prop ] [ custom-infer ] }
        { [ dup "inferred-effect" word-prop ] [ cached-infer ] }
        { [ t ] [ dup infer-word apply-effect/vars ] }
    } cond ;

M: word apply-object apply-word ;

M: symbol apply-object apply-literal ;

TUPLE: recursive-declare-error word ;

: declared-infer ( word -- )
    dup stack-effect [
        consume/produce
    ] [
        <recursive-declare-error> inference-error
    ] if* ;

: apply-inline ( word -- )
    dup recursive-state get peek first eq?
    [ declared-infer ] [ inline-closure ] if ;

: apply-compound ( word -- )
    dup recursing? [ declared-infer ] [ apply-word ] if ;

: custom-infer-vars ( word -- )
    dup "infer-vars" word-prop dup [
        swap "inferred-effect" word-prop effect-in ensure-values
        call
    ] [
        2drop
    ] if ;

M: compound apply-object
    dup custom-infer-vars
    [ apply-inline ] [ apply-compound ] if-inline ;
