! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors generic interpreter kernel lists math
math-internals namespaces sequences strings vectors words
hashtables parser prettyprint ;

: consume-values ( n node -- )
    over ensure-values
    over 0 rot node-inputs [ pop-d 2drop ] each ;

: produce-values ( n node -- )
    over [ drop <value> push-d ] each 0 swap node-outputs ;

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

TUPLE: rstate label quot base-case? ;

: with-recursive-state ( word label base-case quot -- )
    >r >r over word-def r> <rstate> cons
    recursive-state [ cons ] change r>
    call
    recursive-state [ cdr ] change ; inline

: inline-block ( word base-case -- node-block )
    >r gensym 2dup r> [
        [
            dup #label >r
            #entry node,
            swap word-def infer-quot
            #return node, r>
        ] with-nesting
    ] with-recursive-state ;

: infer-compound ( word base-case -- terminates? effect )
    #! Infer a word's stack effect in a separate inferencer
    #! instance. Outputs a boolean if the word terminates
    #! control flow by throwing an exception or restoring a
    #! continuation.
    [
        recursive-state get init-inference
        over >r inline-block drop terminated? get effect r>
    ] with-scope over consume/produce over [ terminate ] when ;

GENERIC: apply-word

M: object apply-word ( word -- )
    #! A primitive with an unknown stack effect.
    no-effect ;

M: compound apply-word ( word -- )
    #! Infer a compound word's stack effect.
    [
        dup dup f infer-compound
        >r "terminates" set-word-prop r>
        "infer-effect" set-word-prop
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
    meta-d get clone >r
    over t inline-block drop
    [ #call-label ] [ #call ] ?if
    r> over set-node-in-d node, ;

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
        "See the handbook for details."
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
    ] if ;

M: compound apply-object ( word -- )
    #! Apply the word's stack effect to the inferencer state.
    dup recursive-state get assoc [
        recursive-word
    ] [
        dup "inline" word-prop
        [ f inline-block block, ] [ apply-default ] if
    ] if* ;
