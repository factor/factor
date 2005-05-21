! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors generic interpreter kernel lists math
math-internals namespaces sequences strings vectors words
hashtables parser prettyprint ;

: consume-d ( typelist -- )
    [ pop-d 2drop ] each ;

: produce-d ( typelist -- )
    [ <computed> push-d ] each ;

: consume/produce ( word effect -- )
    #! Add a node to the dataflow graph that consumes and
    #! produces a number of values.
    swap #call [
        over [
            2unlist swap consume-d produce-d
        ] hairy-node
    ] keep node, ;

: no-effect ( word -- )
    "Unknown stack effect: " swap word-name append
    inference-error ;

: inhibit-parital ( -- )
    meta-d get [ f swap set-value-safe? ] each ;

: recursive? ( word -- ? )
    f swap dup word-def [ = or ] tree-each-with ;

: with-block ( word [[ label quot ]] quot -- block-node )
    #! Execute a quotation with the word on the stack, and add
    #! its dataflow contribution to a new #label node in the IR.
    >r 2dup cons recursive-state [ cons ] change r>
    [ swap car #label slip ] with-nesting
    recursive-state [ cdr ] change ; inline

: inline-block ( word -- node-block )
    gensym over word-def cons [
        inhibit-parital  word-def infer-quot
    ] with-block ;

: inline-compound ( word -- )
    #! Infer the stack effect of a compound word in the current
    #! inferencer instance. If the word in question is recursive
    #! we infer its stack effect inside a new block.
    dup recursive? [
        inline-block node,
    ] [
        word-def infer-quot
    ] ifte ;

: (infer-compound) ( word base-case -- effect )
    #! Infer a word's stack effect in a separate inferencer
    #! instance.
    [
        inferring-base-case set
        recursive-state get init-inference
        dup inline-block drop
        effect present-effect
    ] with-scope [ consume/produce ] keep ;

: infer-compound ( word -- )
    [
        dup f (infer-compound) "infer-effect" set-word-prop
    ] [
        [ swap t "no-effect" set-word-prop rethrow ] when*
    ] catch ;

GENERIC: (apply-word)

M: object (apply-word) ( word -- )
    #! A primitive with an unknown stack effect.
    no-effect ;

M: primitive (apply-word) ( word -- )
    dup "infer-effect" word-prop consume/produce ;

M: compound (apply-word) ( word -- )
    #! Infer a compound word's stack effect.
    dup "no-effect" word-prop [
        no-effect
    ] [
        infer-compound
    ] ifte ;

M: symbol (apply-word) ( word -- )
    apply-literal ;

GENERIC: apply-word

: apply-default ( word -- )
    dup "infer-effect" word-prop [
        over "infer" word-prop [
            swap car ensure-d call drop
        ] [
            consume/produce
        ] ifte*
    ] [
        (apply-word)
    ] ifte* ;

M: word apply-word ( word -- )
    apply-default ;

M: compound apply-word ( word -- )
    dup "inline" word-prop [
        inline-compound
    ] [
        apply-default
    ] ifte ;

: (base-case) ( word label -- )
    over "inline" word-prop [
        over inline-block drop
        [ #call-label ] [ #call ] ?ifte node,
    ] [
        drop dup t (infer-compound) "base-case" set-word-prop
    ] ifte ;

: base-case ( word label -- )
    [
        inferring-base-case on
        (base-case)
    ] [
        inferring-base-case off
        rethrow
    ] catch ;

: no-base-case ( word -- )
    word-name " does not have a base case." append
    inference-error ;

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
                drop no-base-case
            ] [
                car base-case
            ] ifte
        ] ifte*
    ] ifte* ;

M: word apply-object ( word -- )
    #! Apply the word's stack effect to the inferencer state.
    dup recursive-state get assoc [
        recursive-word
    ] [
        apply-word
    ] ifte* ;

\ call [
    pop-literal infer-quot-value
] "infer" set-word-prop

\ execute [
    pop-literal unit infer-quot-value
] "infer" set-word-prop

! These hacks will go away soon
\ delegate [ [ object ] [ object ] ] "infer-effect" set-word-prop
\ no-method t "terminator" set-word-prop
\ no-method [ [ object word ] [ ] ] "infer-effect" set-word-prop
\ <no-method> [ [ object object ] [ tuple ] ] "infer-effect" set-word-prop
\ set-no-method-generic [ [ object tuple ] [ ] ] "infer-effect" set-word-prop
\ set-no-method-object [ [ object tuple ] [ ] ] "infer-effect" set-word-prop
\ not-a-number t "terminator" set-word-prop
\ inference-error t "terminator" set-word-prop
\ throw t "terminator" set-word-prop
\ = [ [ object object ] [ boolean ] ] "infer-effect" set-word-prop
\ integer/ [ [ integer integer ] [ rational ] ] "infer-effect" set-word-prop
\ gcd [ [ integer integer ] [ integer integer ] ] "infer-effect" set-word-prop
