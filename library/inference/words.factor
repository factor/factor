! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors generic interpreter kernel lists math
math-internals namespaces sequences strings vectors words
hashtables parser prettyprint ;

: consume-d ( typelist -- )
    [ pop-d 2drop ] each ;

: produce-d ( typelist -- )
    [ drop <computed> push-d ] each ;

: hairy-node ( node effect quot -- quot: -- )
    over car ensure-d
    -rot 2dup car length 0 rot node-inputs
    2slip
    second length 0 rot node-outputs ; inline

: consume/produce ( word effect -- )
    #! Add a node to the dataflow graph that consumes and
    #! produces a number of values.
    swap #call [
        over [
            first2 swap consume-d produce-d
        ] hairy-node
    ] keep node, ;

: no-effect ( word -- )
    "Stack effect inference of the word " swap word-name
    " was already attempted, and failed" append3
    inference-error ;

: with-recursive-state ( word label quot -- )
    >r over word-def cons cons
    recursive-state [ cons ] change r>
    call
    recursive-state [ cdr ] change ; inline

: inline-block ( word -- node-block )
    gensym 2dup [
        [
            dup #label >r
            #entry node,
            swap word-def infer-quot
            #return node, r>
        ] with-nesting
    ] with-recursive-state ;

: infer-compound ( word base-case -- effect )
    #! Infer a word's stack effect in a separate inferencer
    #! instance.
    [
        inferring-base-case set
        recursive-state get init-inference
        dup inline-block drop
        effect
    ] with-scope [ consume/produce ] keep ;

GENERIC: apply-word

M: object apply-word ( word -- )
    #! A primitive with an unknown stack effect.
    no-effect ;

M: compound apply-word ( word -- )
    #! Infer a compound word's stack effect.
    [
        dup f infer-compound "infer-effect" set-word-prop
    ] [
        [ swap t "no-effect" set-word-prop rethrow ] when*
    ] catch ;

: apply-default ( word -- )
    dup "no-effect" word-prop [
        no-effect
    ] [
        dup "infer-effect" word-prop [
            over "infer" word-prop [
                swap car ensure-d call drop
            ] [
                consume/produce
            ] ifte*
        ] [
            apply-word
        ] ifte*
    ] ifte ;

M: word apply-object ( word -- )
    apply-default ;

M: symbol apply-object ( word -- )
    apply-literal ;

: (base-case) ( word label -- )
    over "inline" word-prop [
        meta-d get clone >r
        over inline-block drop
        [ #call-label ] [ #call ] ?ifte
        r> over set-node-in-d node,
    ] [
        drop dup t infer-compound "base-case" set-word-prop
    ] ifte ;

: base-case ( word label -- )
    [
        inferring-base-case on
        (base-case)
    ] [
        inferring-base-case off
        rethrow
    ] catch ;

: recursive-word ( word [[ label quot ]] -- )
    #! Handle a recursive call, by either applying a previously
    #! inferred base case, or raising an error. If the recursive
    #! call is to a local block, emit a label call node.
    over "infer-effect" word-prop [
        nip consume/produce
    ] [
        over "base-case" word-prop [
            nip consume/produce
        ] [
            inferring-base-case get [
                t base-case-continuation get call
            ] [
                car base-case
            ] ifte
        ] ifte*
    ] ifte* ;

: splice-node ( node -- )
    dup node-successor [
        dup node, penultimate-node f over set-node-successor
        dup current-node set
    ] when drop ;

: block, ( block -- )
    #! If the block does not call itself, there is no point in
    #! having the block node in the IR. Just add its contents.
    dup recursive-label? [
        node,
    ] [
        node-child node-successor splice-node
    ] ifte ;

M: compound apply-object ( word -- )
    #! Apply the word's stack effect to the inferencer state.
    dup recursive-state get assoc [
        recursive-word
    ] [
        dup "inline" word-prop
        [ inline-block block, ] [ apply-default ] ifte
    ] ifte* ;
